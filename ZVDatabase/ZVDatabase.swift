//
//  ZVDatabase.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit

public class ZVConnection: NSObject {
    
    private var _connection: OpaquePointer? = nil
    public var connection: OpaquePointer? { get {return _connection } }
    
    public private(set) var databasePath: String = ""
    
    public private(set) var inTransaction: Bool = false
    
    public override init() {}
    
    public convenience init(path: String) {
        self.init()
        self.databasePath = path
    }
    
    deinit {
        sqlite3_close(_connection)
        _connection = nil
    }
    
    public func open(readonly: Bool = false, vfs vfsName: String? = nil) throws {
    
        if databasePath.isEmpty {
            let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
            self.databasePath = library! + "/db.sqlite"
        }
        
        let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        
        let errCode = sqlite3_open_v2(self.databasePath, &_connection, flags, vfsName)
        guard errCode == SQLITE_OK else {
            let errMsg = "sqlite open error: \(self.lastErrorMsg)"
            throw ZVDatabaseError.error(code: errCode, msg: errMsg);
        }
        
        if maxBusyRetryTime > 0.0 {
            self.setMaxBusyRetry(timeOut: self.maxBusyRetryTime)
        }
        
    }
    
    public func close() throws {
        
        if _connection == nil { return }
        let errCode = sqlite3_close(_connection)
        guard errCode == SQLITE_OK else {
            let errMsg = "sqlite close error: \(self.lastErrorMsg)"
            throw ZVDatabaseError.error(code: errCode, msg: errMsg)
        }
    }
    
    public func executeUpdate(_ sql: String,
                              parameters:[AnyObject?]? = nil) throws {
        
        let statement = ZVStatement(self, sql: (sql as NSString).utf8String, parameters: parameters)
        try statement.prepare()
        try statement.execute()
    }
    
    public func exceuteUpdate(_ sql: String,
                              parameters:[AnyObject?]? = nil,
                              lastInsertRowid: Bool = false) throws -> Int64? {
        
        let statement = ZVStatement(self, sql: (sql as NSString).utf8String, parameters: parameters)
        try statement.prepare()
        try statement.execute()
        
        if lastInsertRowid {
            return self.lastInsertRowid
        } else {
            return Int64(self.changes)
        }   
    }
    
    public func executeQuery(_ sql: String,
                             parameters:[AnyObject?]? = nil) throws -> [ZVSQLRow] {
        
        let statement = ZVStatement(self, sql: (sql as NSString).utf8String, parameters: parameters)
        try statement.prepare()
        let rows = try statement.query()
        return rows
    }
    
    public func executeQuery(forDictionary sql: String,
                             parameters:[AnyObject?]? = nil) throws -> [[String: AnyObject?]] {
        
        let statement = ZVStatement(self, sql: sql, parameters: parameters)
        try statement.prepare()
        let rows = try statement.query(forDictionary: true)
        return rows
    }
    
    public func beginTransaction() -> Bool {
        
        let sql = "BEGIN EXCLUSIVE TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.inTransaction = true
        }
        return self.inTransaction
    }
    
    public func beginDeferredTransaction() -> Bool {
        
        let sql = "BEGIN DEFERRED TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.inTransaction = true
        }
        return self.inTransaction
    }
    
    public func rollback() {
        
        defer {
            if self.inTransaction {
                self.inTransaction = false
            }
        }
        
        let sql = "ROLLBACK TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.inTransaction = true
        } else {
            
        }
    }
    
    public func commit() {
        
        defer {
            if self.inTransaction {
                self.inTransaction = false
            }
        }
        
        let sql = "COMMIT TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.inTransaction = true
        }
    }
    
    // MARK: - BusyHandler
    private var startBusyRetryTime: TimeInterval = 0.0
    
    public var maxBusyRetryTime: TimeInterval = 2.0 {
        didSet (timeOut) {
            self.setMaxBusyRetry(timeOut: timeOut)
        }
    }
    
    private func setMaxBusyRetry(timeOut: TimeInterval) {
        
        if _connection == nil {
            return;
        }
        
        if timeOut > 0 {
            sqlite3_busy_handler(_connection, nil, nil)
        } else {
            sqlite3_busy_handler(_connection, { (dbPointer, retry) -> Int32 in
                
                let connection = unsafeBitCast(dbPointer, to: ZVConnection.self)
                return connection.busyHandler(dbPointer, retry)
                }, unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self))
        }
    }
    
    private var busyHandler: ZVBusyHandler = { (dbPointer: UnsafeMutablePointer<Void>?, retry: Int32) -> Int32 in
        let connection = unsafeBitCast(dbPointer, to: ZVConnection.self)
        
        if retry == 0 {
            connection.startBusyRetryTime = Date.timeIntervalSinceReferenceDate
            return 1
        }
        
        let delta = Date.timeIntervalSinceReferenceDate - connection.startBusyRetryTime
        
        if (delta < connection.maxBusyRetryTime) {
            
            let requestedSleep = Int32(arc4random_uniform(50) + 50)
            let actualSleep = sqlite3_sleep(requestedSleep);
            if actualSleep != requestedSleep {
                print("WARNING: Requested sleep of \(requestedSleep) milliseconds, but SQLite returned \(actualSleep). Maybe SQLite wasn't built with HAVE_USLEEP=1?" )
            }
            
            return 1
        }
        
        return 0
    }
    
    // MARK: -
    public var lastInsertRowid: Int64? {
        
        let rowid = sqlite3_last_insert_rowid(_connection)
        return rowid != 0 ? rowid : nil
    }
    
    public var changes: Int {
        
        let rows = sqlite3_changes(_connection)
        return Int(rows)
    }
    
    public var totalChanges: Int {
        return Int(sqlite3_total_changes(_connection))
    }
    
    public var lastErrorMsg: String {
        
        let errMsg = String(cString: sqlite3_errmsg(_connection))
        return errMsg
    }
}
