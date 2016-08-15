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
    public private(set) var hasSavePoint: Bool = false
    
    public override init() {}
    
    public convenience init(path: String) {
        self.init()
        self.databasePath = path
    }
    
    deinit {
        sqlite3_close(_connection)
        _connection = nil
    }
    
    /**
     创建一个新的数据库
     
     - parameter readonly: 判断数据库打开属性，是否只读
     - parameter vfsName:
     
     - throws: 数据库打开异常
     */
    public func open(readonly: Bool = false, vfs vfsName: String? = nil) throws {
    
        if databasePath.isEmpty {
            let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
            let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "sqlite"
            self.databasePath = library! + "/" + identifier + ".db"
        }
        
        let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        
        let errCode = sqlite3_open_v2(self.databasePath, &_connection, flags, vfsName)
        guard errCode.isSuccess else {
            let errMsg = "sqlite open error: \(self.lastErrorMsg)"
            throw DatabaseError.error(code: errCode, msg: errMsg);
        }
        
        if maxBusyRetryTime > 0.0 {
            _setMaxBusyRetry(timeOut: self.maxBusyRetryTime)
        }
        
    }
    
    /**
     关闭并摧毁一个数据库
     
     - throws:
     */
    public func close() throws {
        
        if _connection == nil { return }
        let errCode = sqlite3_close(_connection)
        
        guard errCode.isSuccess else {
            let errMsg = "sqlite close error: \(self.lastErrorMsg)"
            throw DatabaseError.error(code: errCode, msg: errMsg)
        }
    }
    
    /**
     执行SQL语句
     
     - parameter sql:        String
     - parameter parameters: An array which element implement Bindable
     
     - throws:
     */
    public func executeUpdate(_ sql: String,
                              parameters:[Bindable] = []) throws {
        
        let _sql = (sql as NSString).utf8String
        let statement = try Statement(self, sql: _sql, parameters: parameters)
        try statement.execute()
    }
    
    /**
     执行SQL语句
     
     - parameter sql:             String
     - parameter parameters:      An array which element implement Bindable
     - parameter lastInsertRowid: 返回数据库改变行数或者最后一行数据id
     
     - throws:
     
     - returns: 返回一个Int64的数值
     */
    public func exceuteUpdate(_ sql: String,
                              parameters:[Bindable] = [],
                              lastInsertRowid: Bool = false) throws -> Int64? {
        
        let _sql = (sql as NSString).utf8String
        let statement = try Statement(self, sql: _sql, parameters: parameters)
        try statement.execute()
        
        if lastInsertRowid {
            return self.lastInsertRowid
        } else {
            return Int64(self.changes)
        }   
    }
    
    /**
     执行SQL语句
     
     - parameter sql:        String
     - parameter parameters: An array which element implement Bindable
     
     - throws:
     
     - returns: 返回一个字典数组
     */
    public func executeQuery(_ sql: String,
                             parameters:[Bindable] = []) throws -> [[String: AnyObject]] {
        
        let statement = try Statement(self, sql: sql, parameters: parameters)
        let rows = try statement.query()
        return rows
    }
    
    // MARK: - Transaction
    
    /**
     开始一个数据库事务
     
     - parameter transaction: 事务类型 详参 @see http://www.sqlite.org/lang_transaction.html
     - returns:
     */
    public func begin(transaction type: TransactionType) -> Bool {
        
        var success = false
        
        switch type {
        case .deferred:
            success = self._beginDeferredTransaction()
            break
        case .exclusive:
            success = self._beginExclusiveTransaction()
            break
        case .immediate:
            success = self._beginImmediateTransaction()
            break
        }
        
        return success
    }
    
    private func _beginExclusiveTransaction() -> Bool {
        
        let sql = "BEGIN EXCLUSIVE TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil).isSuccess {
            self.hasTransaction = true
        }
        return self.hasTransaction
    }
    
    private func _beginDeferredTransaction() -> Bool {
        
        let sql = "BEGIN DEFERRED TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil).isSuccess {
            self.hasTransaction = true
        }
        return self.hasTransaction
    }
    
    private func _beginImmediateTransaction() -> Bool {
        
        let sql = "BEGIN IMMEDIATE TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil).isSuccess {
            self.hasTransaction = true
        }
        return self.hasTransaction
    }
    
    /**
     回滚事务
     */
    public func rollback() {
        
        defer {
            if self.hasTransaction {
                self.hasTransaction = false
            }
        }
        
        let sql = "ROLLBACK TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil).isSuccess {
            self.hasTransaction = true
        } else {
            
        }
    }
    
    /**
     提交事务
     */
    public func commit() {
        
        defer {
            if self.hasTransaction {
                self.hasTransaction = false
            }
        }
        
        let sql = "COMMIT TRANSACTION"
        if sqlite3_exec(_connection, sql, nil, nil, nil).isSuccess {
            self.hasTransaction = true
        }
    }
    
    //MARK: - SAVEPOINT
    
    /**
     开启一个数据库SAVEPOINT
     @see http://www.sqlite.org/lang_savepoint.html
     
     - parameter name: String
     
     - returns:
     */
    public func beginSavepoint(with name: String) -> Bool {
        
        let sql = "SAVEPOINT " + name
        
        if sqlite3_exec(_connection, sql, nil, nil, nil).isSuccess {
            self.hasSavePoint = true
        }
        
        return self.hasSavePoint
    }
    
    /**
     回滚一个SAVEPOINT
     
     - parameter name: String
     */
    public func rollbackSavepoint(with name: String) {
        
        let sql = "ROLLBACK TO SAVEPOINT " + name
        
        if sqlite3_exec(_connection, sql, nil, nil, nil).isSuccess {
            self.hasSavePoint = false
        }
    }
    
    /**
     提交一个SAVEPOINT
     
     - parameter name: String
     */
    public func releaseSavepoint(with name:String) {
        
        let sql = "RELEASE " + name
        
        if sqlite3_exec(_connection, sql, nil, nil, nil).isSuccess {
            self.hasSavePoint = true
        }
    }
    
    // MARK: - BusyHandler
    private var _startBusyRetryTime: TimeInterval = 0.0
    
    ///
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
    /// last insert rowid
    public var lastInsertRowid: Int64? {
        
        let rowid = sqlite3_last_insert_rowid(_connection)
        return rowid != 0 ? rowid : nil
    }
    
    /// change rows
    public var changes: Int {
        
        let rows = sqlite3_changes(_connection)
        return Int(rows)
    }
    
    /// total change rows
    public var totalChanges: Int {
        return Int(sqlite3_total_changes(_connection))
    }
    
    /// last error message
    public var lastErrorMsg: String {
        
        let errMsg = String(cString: sqlite3_errmsg(_connection))
        return errMsg
    }
}
