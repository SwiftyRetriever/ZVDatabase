//
//  ZVDatabasePool.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit

public protocol DatabasePoolDelegate : class {
    
    /**
     <#Description#>
     
     - parameter database: <#database description#>
     
     - throws: <#throws value description#>
     */
    func databaseOpened(_ database: Connection) throws
    
    /**
     <#Description#>
     
     - parameter database: <#database description#>
     */
    func databaseClosed(_ database: Connection)
    
}

public final class DatabasePool {

    private var _lockQueue: DispatchQueue?
    private var _readOnly: Bool = false
    private var _vfsName: String? = nil
    private var _databasePath: String? = nil
    
    public weak var delegate : DatabasePoolDelegate?

    /**
     <#Description#>
     
     - returns: <#return value description#>
     */
    public init() {
        _lockQueue = DispatchQueue(label: "com.zevwings.db.locked")
    }
    
    /**
     
     - parameter path:     String
     - parameter readOnly: Bool
     - parameter vfsName:  String
     
     */
    public convenience init(path: String, readOnly: Bool = false, vfs vfsName: String? = nil) {
        self.init()
        _databasePath = path
        _readOnly = readOnly
        _vfsName = vfsName
    }
    
    /**
     
     - parameter path:     String
     - parameter delegate: DatabasePoolDelegate
     
     */
    public convenience init(path: String? = nil, delegate: DatabasePoolDelegate? = nil) {
        self.init()
        _databasePath = path
        self.delegate = delegate
    }
    
    
    deinit {
        
        _inactiveDatabases.removeAll()
        _activeDatabases.removeAll()
        
        _lockQueue = nil
        _vfsName = nil
        self.delegate = nil
        _databasePath = nil
    }
    
    private var _array = Array<Connection>()
    private var _inactiveDatabases   = [Connection]()
    private var _activeDatabases     = [Connection]()
    
    /// inactive database count
    public var inactiveDatabaseCount : Int {
        return _inactiveDatabases.count
    }
    
    /// active database count
    public var activeDatabaseCount : Int {
        return _activeDatabases.count
    }

    /**
     从队列中取出数据库
     
     - throws:
     
     - returns: Connection
     */
    public func dequeueDatabase() throws -> Connection {
        var database: Connection?
        var error: NSError?
        _lockQueue?.sync {
            if _inactiveDatabases.isEmpty {
                do {
                    database = try _open()
                    _activeDatabases.append(database!)
                } catch let openError as NSError {
                    error = openError
                    return
                } catch let e {
                    fatalError("Unexpected error thrown opening a database \(e)")
                }
            } else {
                database = _inactiveDatabases.removeLast()
                _activeDatabases.append(database!)
            }
        }
        
        guard let dequeuedDatabase = database else {
            throw error!
        }
        
        return dequeuedDatabase
    }
    
    /**
     添加数据库到队列中
     
     - parameter database: Connection
     */
    public func enqueueDatabase(database: Connection) {
        _deactivate(database: database)
        _lockQueue?.sync(execute: {
            _inactiveDatabases.append(database)
        })
    }
    
    /**
     从队列中移除数据库
     
     - parameter database: Connection
     */
    public func removeDatabase(database: Connection) {
        _deactivate(database: database)
    }
    
    /**
     将队列中所有数据库移除
     */
    public func drain() {
        _lockQueue?.sync(execute: { 
            _inactiveDatabases.removeAll(keepingCapacity: false)
        })
    }
    
    private func _open() throws -> Connection {
        
        var database: Connection?
        if let databasePath = _databasePath {
            database = Connection(path: databasePath)
        } else {
            database = Connection()
        }
        if let db = database {
            try db.open(readonly: _readOnly, vfs: _vfsName)
            try self.delegate?.databaseOpened(db)
        }
        return database!
    }
    
    private func _deactivate(database: Connection) {
        
        _lockQueue?.sync(execute: { 
            
            if let index = _activeDatabases.index(of: database) {
                self._activeDatabases.remove(at: index)
            }
            
            if let index = _inactiveDatabases.index(of: database) {
                self._inactiveDatabases.remove(at: index)
            }
            
            self.delegate?.databaseClosed(database)
        })
    }
    
    /**
     在数据库池中执行数据库
     
     - parameter block: Closure
     
     - throws:
     */
    public func inBlock(_ block: (db: Connection) -> Void) throws {
        
        let db = try self.dequeueDatabase()
        block(db: db)
        self.enqueueDatabase(database: db)
    }
    
    /**
     在数据库池中执行数据库并开启事务
     
     - parameter type:  事务类型
     - parameter block: Closure
     
     - throws: 
     */
    public func inTransaction(transactionType type: TransactionType = .deferred, _ block: (db: Connection) -> Bool) throws {
        
        let db: Connection = try self.dequeueDatabase()
        
        let success = db.begin(transaction: type)
        
        if success {
            if block(db: db) {
                db.commit()
                self.enqueueDatabase(database: db)
            } else {
                db.rollback()
                self.enqueueDatabase(database: db)
            }
        } else {
            self.enqueueDatabase(database: db)
        }
    }
}
