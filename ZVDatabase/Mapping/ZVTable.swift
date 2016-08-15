//
//  ZVTable.swift
//  ZVDatabase
//
//  Created by naver on 16/7/28.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

private var gSingleton: [String: Any] = [:]

public protocol ZVTableProtocol {
    
    init()
    func databasePath() -> String?
    func tableName() -> String
}

public class ZVTable<V: ZVObject>: ZVTableProtocol {

    internal var commands: [Command] = []
    
    public required init () {}
    
    deinit {}
    
    public func databasePath() -> String? {
        return nil
    }
    
    public func tableName() -> String {
        return String(V.self)
    }
    
    private var shared: V {
        
        let key = String(V.self)
        var shared: V?
        if let obj = gSingleton[key] as? V {
            shared = obj
        } else {
            shared = V.init()
            gSingleton[key] = shared
        }
        return shared!
    }
}

//MARK: - Schema
public extension ZVTable {
    
    public func create() {
        
        let cmd = Schema(create: self.tableName(), fields: self.shared.fields())
        self.commands.append(cmd)
    }
    
    public func drop() {
        
        let cmd = Schema(drop: self.tableName())
        self.commands.append(cmd)
    }
    
    public func add(column: String, info: String) {
        
        let cmd = Schema(add: column, info: info, for: self.tableName())
        self.commands.append(cmd)
    }
    
    public func delete(colmun column: String) {
        
        let cmd = Schema(delete: column, from: self.tableName())
        self.commands.append(cmd)
    }
    
    public func alert(column: String, info: String) {
        
        let cmd = Schema(alert: column, info: info, for: self.tableName())
        self.commands.append(cmd)
    }
}

//MARK: - CRUD

public typealias errorBlock = ((error: Error) -> Void)
public typealias resultBlock = (result: [[String: AnyObject]]) -> Void
public typealias objResultBlock = (result: [ZVObject]) -> Void


public extension ZVTable {
    
    public func insert(_ object: ZVObject) {
        
        let cmd = Insert(object.dictionaryValue(), into: self.tableName())
        self.commands.append(cmd)
    }
    
    public func insert(_ column: [String],
                       parameters: [Bindable] = []) {
        
        let cmd = Insert(column, parameters: parameters, into: self.tableName())
        self.commands.append(cmd)
    }
    
    public func update(object: ZVObject) {
        
        var values = object.dictionaryValue()
        var primaryKey: Bindable = ""
        
        if let pk = object.primaryKey()?.key {
            
            primaryKey = values[pk] ?? ""
            values.removeValue(forKey: pk)
            
            let cmd = Update(values, table: self.tableName())
                .where(pk, equalTo: primaryKey)
            self.commands.append(cmd)
        } else {
            print("the primary key is not figure out.")
        }
    }
    
    public func update(_ values: [String: Bindable],
                       where command: Where? = nil) {
        
        let cmd = Update(values, table: self.tableName()).appending(command!)
        self.commands.append(cmd)
    }
    
    public func delete(where command: Where? = nil) {
        
        let cmd = Delete(from: self.tableName()).appending(command)
        self.commands.append(cmd)
    }
    
    public func select(_ rows: [String] = [],
                       where command: Where? = nil) throws -> [[String: AnyObject]] {
        
        let fields = rows.isEmpty ? self.shared.fields().map({ (key, _) in return key }) : rows
        let cmd = Select(fields, from: self.tableName()).appending(command)
        return try self.query(by: cmd)
    }
    
    public func select(_ rows: [String] = [],
                       where command: Where? = nil,
                       inBackground: Bool = false,
                       rs result: resultBlock,
                       error block: errorBlock? = nil) {
        
        let fields = rows.isEmpty ? self.shared.fields().map({ (key, _) in return key }) : rows
        let cmd = Select(fields, from: self.tableName()).appending(command)
        self.query(by: cmd, inBackground: inBackground, rs: result, error: block)
    }
    
    /*
    public func select(_ rows: [String] = [],
                       where command: Where? = nil,
                       inBackground: Bool = false,
                       rs result: objResultBlock,
                       error block: errorBlock? = nil) {
        
        let fields = rows.isEmpty ? self.shared.fields().map({ (key, _) in return key }) : rows
        let cmd = Select(fields, from: self.tableName()).appending(command)
        self.query(by: cmd, inBackground: inBackground, rs: result, error: block)
    }*/
}

//MARK: - Execute

public extension ZVTable {
    
    public func excute(inBackground: Bool = false,
                       error block: errorBlock? = nil) {
        
        if inBackground {
            _executeInBackground(error: block)
        } else {
            _excute(error: block)
        }
    }
    
    private func _excute(error block: errorBlock? = nil) {
        
        let db = Connection(path: self.databasePath() ?? "")
        do {
            try db.open()
            print(db.databasePath)
            for cmd in self.commands {
                try cmd.execute(with: db)
            }
            try db.close()
        } catch {
            block?(error: error)
        }
        
        self.commands.removeAll()
    }
    
    private func _executeInBackground(error block: errorBlock? = nil) {
        
        let queue = DatabaseQueue(path: self.databasePath() ?? "")
        queue.inTransaction({ (db) -> Bool in
            print(db.databasePath)
            var success: Bool = true
            do {
                for cmd in self.commands {
                    try cmd.execute(with: db)
                }
            } catch {
                success = false
                block?(error: error)
            }
            
            self.commands.removeAll()
            return success
        })
    }
}

//MARK: - Query
public extension ZVTable {
    
    public func query(by cmd: Command) throws -> [[String: AnyObject]] {

        let db = Connection(path: self.databasePath() ?? "")
        try db.open()
        let rs = try cmd.query(with: db)
        try db.close()
        
        return rs
    }
    
    public func query(by cmd: Command,
                      inBackground: Bool = false,
                      rs result: resultBlock,
                      error block: errorBlock? = nil) {
        
        if inBackground {
            _queryInBackground(by: cmd, rs: result, error: block)
        } else {
            _query(by: cmd, rs: result, error: block)
        }
    }

    private func _query(by cmd: Command,
                        rs result: resultBlock,
                        error block: errorBlock? = nil) {
        
        let db = Connection(path: self.databasePath() ?? "")
        do {
            try db.open()
            let rs = try cmd.query(with: db)
            result(result: rs)
            try db.close()
        } catch {
            block?(error: error)
        }
    }
    
    private func _queryInBackground(by cmd: Command,
                                    rs result: resultBlock,
                                    error block: errorBlock? = nil) {
        
        let queue = DatabaseQueue(path: self.databasePath() ?? "")
        queue.inBlock { (db) in
            
            do {
                try db.open()
                let rs = try cmd.query(with: db)
                result(result: rs)
                try db.close()
            } catch {
                block?(error: error)
            }
        }
    }
}

extension ZVTable {
    /*
    public func query(by cmd: Command) throws -> [ZVObject] {
        let db = Connection(path: self.databasePath() ?? "")
        try db.open()
        // let rs = try cmd.query(with: db)
        try db.close()
        
        return []
    }
    
    public func query(by cmd: Command,
                      inBackground: Bool = false,
                      rs result: objResultBlock,
                      error block: errorBlock? = nil) {
        
        if inBackground {
            _queryInBackground(by: cmd, rs: result, error: block)
        } else {
            _query(by: cmd, rs: result, error: block)
        }
    }
    
    private func _query(by cmd: Command,
                        rs result: objResultBlock,
                        error block: errorBlock? = nil) {
        
        let db = Connection(path: self.databasePath() ?? "")
        do {
            try db.open()
            let _ = try cmd.query(with: db)
            // result(result: rs)
            try db.close()
        } catch {
            block?(error: error)
        }
    }
    
    private func _queryInBackground(by cmd: Command,
                                    rs result: objResultBlock,
                                    error block: errorBlock? = nil) {
        
        let queue = DatabaseQueue(path: self.databasePath() ?? "")
        queue.inBlock { (db) in
            
            do {
                try db.open()
                let _ = try cmd.query(with: db)
                
                // result(result: rs)
                try db.close()
            } catch {
                block?(error: error)
            }
        }
    }*/
}
