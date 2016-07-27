//
//  ZVDatabase.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit

#if os(OSX)
    import SQLiteMacOS
#elseif os(iOS)
    #if (arch(i386) || arch(x86_64))
        import SQLiteiPhoneSimulator
    #else
        import SQLiteiPhoneOS
    #endif
#endif

public final class Connection: NSObject {
    
    private var _connection: SQLite3? = nil
    public var connection: SQLite3? { return _connection }
    
    public private(set) var databasePath: String = ""
    
    public private(set) var hasTransaction: Bool = false
    
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
            let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "sqlite"
            self.databasePath = library! + "/" + identifier + ".db"
        }
        
        let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        
        let errCode = sqlite3_open_v2(self.databasePath, &_connection, flags, vfsName)
        guard errCode == SQLITE_OK else {
            let errMsg = "sqlite open error: \(self.lastErrorMsg)"
            throw DatabaseError.error(code: errCode, msg: errMsg);
        }
        
        if maxBusyRetryTime > 0.0 {
            _setMaxBusyRetry(timeOut: self.maxBusyRetryTime)
        }
        
    }
    
    public func close() throws {
        
        if _connection == nil { return }
        let errCode = sqlite3_close(_connection)
        
        guard errCode == SQLITE_OK else {
            let errMsg = "sqlite close error: \(self.lastErrorMsg)"
            throw DatabaseError.error(code: errCode, msg: errMsg)
        }
    }
    
    public func executeUpdate(_ sql: String,
                              parameters:[Binding] = []) throws {
        
        let _sql = (sql as NSString).utf8String
        let statement = Statement(self, sql: _sql, parameters: parameters)
        try statement.prepare()
        try statement.execute()
    }
    
    public func exceuteUpdate(_ sql: String,
                              parameters:[Binding] = [],
                              lastInsertRowid: Bool = false) throws -> Int64? {
        
        let _sql = (sql as NSString).utf8String
        let statement = Statement(self, sql: _sql, parameters: parameters)
        try statement.prepare()
        try statement.execute()
        
        if lastInsertRowid {
            return self.lastInsertRowid
        } else {
            return Int64(self.changes)
        }   
    }
    
    public func executeQuery(_ sql: String,
                             parameters:[Binding] = []) throws -> [ZVSQLRow] {
        
        let statement = Statement(self, sql: (sql as NSString).utf8String, parameters: parameters)
        try statement.prepare()
        let rows = try statement.query()
        return rows
    }
    
    public func executeQuery(forDictionary sql: String,
                             parameters:[Binding] = []) throws -> [[String: AnyObject?]] {
        
        let statement = Statement(self, sql: sql, parameters: parameters)
        try statement.prepare()
        let rows = try statement.query(forDictionary: true)
        return rows
    }
    
    
    // MARK: - Transaction
    public func beginExclusiveTransaction() -> Bool {
        
        let sql = "BEGIN EXCLUSIVE TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.hasTransaction = true
        }
        return self.hasTransaction
    }
    
    public func beginDeferredTransaction() -> Bool {
        
        let sql = "BEGIN DEFERRED TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.hasTransaction = true
        }
        return self.hasTransaction
    }
    
    public func beginImmediateTransaction() -> Bool {
        
        let sql = "BEGIN IMMEDIATE TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.hasTransaction = true
        }
        return self.hasTransaction
    }
    
    public func rollback() {
        
        defer {
            if self.hasTransaction {
                self.hasTransaction = false
            }
        }
        
        let sql = "ROLLBACK TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.hasTransaction = true
        } else {
            
        }
    }
    
    public func commit() {
        
        defer {
            if self.hasTransaction {
                self.hasTransaction = false
            }
        }
        
        let sql = "COMMIT TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil) == SQLITE_OK {
            self.hasTransaction = true
        }
    }
    
    // MARK: - BusyHandler
    private var _startBusyRetryTime: TimeInterval = 0.0
    
    public var maxBusyRetryTime: TimeInterval = 2.0 {
        didSet (timeOut) {
            _setMaxBusyRetry(timeOut: timeOut)
        }
    }
    
    private func _setMaxBusyRetry(timeOut: TimeInterval) {
        
        if _connection == nil {
            return;
        }
        
        if timeOut > 0 {
            sqlite3_busy_handler(_connection, nil, nil)
        } else {
            sqlite3_busy_handler(_connection, { (dbPointer, retry) -> Int32 in
                
                let connection = unsafeBitCast(dbPointer, to: Connection.self)
                return connection._busyHandler(dbPointer, retry)
                }, unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self))
        }
    }
    
    private var _busyHandler: BusyHandler = { (dbPointer: UnsafeMutablePointer<Void>?, retry: Int32) -> Int32 in
        let connection = unsafeBitCast(dbPointer, to: Connection.self)
        
        if retry == 0 {
            connection._startBusyRetryTime = Date.timeIntervalSinceReferenceDate
            return 1
        }
        
        let delta = Date.timeIntervalSinceReferenceDate - connection._startBusyRetryTime
        
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
