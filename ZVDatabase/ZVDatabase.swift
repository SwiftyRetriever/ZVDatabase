//
//  ZVDatabase.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit
#if arch(i386) || arch(x86_64)
import SQLite3iPhoneSimulator
#else
import SQLite3iPhoneOS
#endif

internal func ZVLog(_ items: Swift.Any..., separator: String = "", terminator: String = "") {
    print(items, separator: separator, terminator: terminator)
}

public enum ZVDatabaseError : ErrorProtocol {
    
    case error(code: Int32, msg: String)
    
}

public class ZVConnection: NSObject {
    
    internal var connection: OpaquePointer? = nil
    
    internal var databasePath: String = ""
    
    public private(set) var inTransaction: Bool = false
    
    public override init() {}
    
    public convenience init(path: String) {
        self.init()
        self.databasePath = path
    }
    
    deinit {
        sqlite3_close(connection)
        connection = nil
    }
    
    public func open() throws {
    
        if databasePath.isEmpty {
            let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
            self.databasePath = library! + "/db.sqlite"
        }
        
        print(databasePath)
        
        let errCode = sqlite3_open(self.databasePath, &connection)
        guard errCode == SQLITE_OK else {
            let errMsg = "sqlite open error: \(self.lastErrorMsg)"
            throw ZVDatabaseError.error(code: errCode, msg: errMsg);
        }
    }
    
    public func close() throws {
        
        if connection == nil { return }
        let errCode = sqlite3_close(connection)
        guard errCode == SQLITE_OK else {
            let errMsg = "sqlite close error: \(self.lastErrorMsg)"
            throw ZVDatabaseError.error(code: errCode, msg: errMsg)
        }
    }
    
    public var lastInsertRowid: Int64? {
        
        let rowid = sqlite3_last_insert_rowid(connection)
        return rowid != 0 ? rowid : nil
    }
    
    public var changes: Int {
        
        let rows = sqlite3_changes(connection)
        return Int(rows)
    }
    
    public var lastErrorMsg: String {
        
        let errMsg = String(cString: sqlite3_errmsg(connection))
        return errMsg
        
    }
    
    public func executeUpdate(_ sql: String,
                              parameters:[AnyObject?]? = nil) throws {
        
        let statement = ZVStatement(self, sql: sql, parameters: parameters)
        try statement.prepare()
        try statement.execute()
    }
    
    public func exceuteUpdate(_ sql: String,
                              parameters:[AnyObject?]? = nil,
                              lastInsertRowid: Bool = false) throws -> Int64? {
        
        let statement = ZVStatement(self, sql: sql, parameters: parameters)
        try statement.prepare()
        try statement.execute()
        
        if lastInsertRowid {
            return self.lastInsertRowid
        } else {
            return Int64(self.changes)
        }   
    }
    
    public func executeQuery(_ sql: String, parameters:[AnyObject?]? = nil) throws -> [ZVRow] {
        
        let statement = ZVStatement(self, sql: sql, parameters: parameters)
        try statement.prepare()
        let rows = try statement.query()
        return rows
    }
    
    public func beginTransaction() -> Bool {
        
        let sql = "begin exclusive transaction"
        if sqlite3_exec(self.connection, sql, nil, nil, nil) == SQLITE_OK {
            self.inTransaction = true
        }
        return self.inTransaction
    }
    
    public func beginDeferredTransaction() -> Bool {
        
        let sql = "begin deferred transaction"
        if sqlite3_exec(self.connection, sql, nil, nil, nil) == SQLITE_OK {
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
        
        let sql = "rollback transaction"
        if sqlite3_exec(self.connection, sql, nil, nil, nil) == SQLITE_OK {
            self.inTransaction = true
        }
    }
    
    public func commit() {
        
        defer {
            if self.inTransaction {
                self.inTransaction = false
            }
        }
        
        let sql = "commit transaction"
        if sqlite3_exec(self.connection, sql, nil, nil, nil) == SQLITE_OK{
            self.inTransaction = true
        }
    }
}
