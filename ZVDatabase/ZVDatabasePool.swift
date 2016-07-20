//
//  ZVDatabasePool.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit

public protocol ZVDatabasePoolDelegate : class {
    
    func databaseOpened(_ database: ZVConnection) throws
    func databaseClosed(_ database: ZVConnection)
    
}

public final class ZVDatabasePool {

    private var _lockQueue: DispatchQueue?
    private var _readOnly: Bool = false
    private var _vfsName: String? = nil
    private var _databasePath: String? = nil
    
    public weak var delegate : ZVDatabasePoolDelegate?

    public init() {
        _lockQueue = DispatchQueue(label: "com.zevwings.db.locked")
    }
    
    public convenience init(path: String, readOnly: Bool = false, vfs vfsName: String? = nil) {
        self.init()
        _databasePath = path
        _readOnly = readOnly
        _vfsName = vfsName
    }
    
    public convenience init(path: String? = nil, delegate: ZVDatabasePoolDelegate? = nil) {
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
    
    private var _array = Array<ZVConnection>()
    private var _inactiveDatabases   = [ZVConnection]()
    private var _activeDatabases     = [ZVConnection]()
    
    public var inactiveDatabaseCount : Int {
        return _inactiveDatabases.count
    }
    
    public var activeDatabaseCount : Int {
        return _activeDatabases.count
    }

    public func dequeueDatabase() throws -> ZVConnection {
        var database: ZVConnection?
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
    
    public func enqueueDatabase(database: ZVConnection) {
        _deactivate(database: database)
        _lockQueue?.sync(execute: {
            _inactiveDatabases.append(database)
        })
    }
    
    public func removeDatabase(database: ZVConnection) {
        _deactivate(database: database)
    }
    
    public func drain() {
        _lockQueue?.sync(execute: { 
            _inactiveDatabases.removeAll(keepingCapacity: false)
        })
    }
    
    private func _open() throws -> ZVConnection {
        
        var database: ZVConnection?
        if let databasePath = _databasePath {
            database = ZVConnection(path: databasePath)
        } else {
            database = ZVConnection()
        }
        if let db = database {
            try db.open(readonly: _readOnly, vfs: _vfsName)
            try self.delegate?.databaseOpened(db)
        }
        return database!
    }
    
    private func _deactivate(database: ZVConnection) {
        
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
    
    public func inBlock(_ block: (db: ZVConnection) -> Void) throws {
        
        let db = try self.dequeueDatabase()
        block(db: db)
        self.enqueueDatabase(database: db)
    }
    
    public func inTransaction(useDeferred deferred: Bool = false, _ block: (db: ZVConnection) -> Bool) throws {
        
        let db: ZVConnection = try self.dequeueDatabase()
        
        var success = false
        if deferred {
            success = db.beginDeferredTransaction()
        } else {
            success = db.beginTransaction()
        }

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
