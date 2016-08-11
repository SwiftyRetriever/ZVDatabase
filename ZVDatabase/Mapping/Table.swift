//
//  ZVTable.swift
//  ZVDatabase
//
//  Created by naver on 16/7/28.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

private var gSingleton: [String: Any] = [:]

public protocol TableProtocol {
    
    init()
    func databasePath() -> String?
    func tableName() -> String
}

public class Table<V: ZVObject>: TableProtocol {

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
extension Table {
    
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
extension Table {
    
    public func insert(_ object: ZVObject) {
        
        let cmd = Insert(object.dictionaryValue(), into: self.tableName())
        self.commands.append(cmd)
    }
    
    public func insert(_ column: [String], parameters: [Bindable] = []) {
        
        let cmd = Insert(column, parameters: parameters, into: self.tableName())
        self.commands.append(cmd)
    }
    
    public func update(object: ZVObject) {
        
        var values = object.dictionaryValue()
        var primaryKey: Bindable = ""
        
        if let pk = object.primaryKey()?.key {
            
            primaryKey = values[pk]!
            values.removeValue(forKey: pk)
            
            let cmd = Update(values, table: self.tableName())
                .where(pk, equalTo: primaryKey)
            self.commands.append(cmd)
        } else {
            print("the primary key is not figure out.")
        }
    }
    
    public func update(_ values: [String: Bindable], where command: Where? = nil) {
        
        var cmd: Command!
        if command == nil {
            cmd = Update(values, table: self.tableName())
        } else {
            cmd = Update(values, table: self.tableName()).appending(command!)
        }
        self.commands.append(cmd)
    }
    
    public func delete(where command: Where? = nil) {
        
        var cmd: Command!
        if command == nil {
            cmd = Delete(from: self.tableName())
        } else {
            cmd = Delete(from: self.tableName()).appending(command!)
        }
        self.commands.append(cmd)
    }
    
    public func select(_ rows: [String] = [], where command: Where? = nil) {
        
        let fields = rows.isEmpty ? self.shared.fields().map({ (key, _) in return key }) : rows
        var cmd: Command!
        
        if command == nil {
            cmd = Select(fields, from: self.tableName())
        } else {
            cmd = Select(fields, from: self.tableName()).appending(command!)
        }
        
        self.commands.append(cmd)
    }
}

//MARK: - Execute
extension Table {
    
    public func excute(inBackground: Bool = false) {
        
        if inBackground {
            _executeInBackground()
        } else {
            _excute()
        }
    }
    
    private func _excute() {
        
        let db = Connection(path: self.databasePath() ?? "")
        do {
            try db.open()
            print(db.databasePath)
            for cmd in self.commands {
                try cmd.execute(with: db)
            }
            try db.close()
        } catch {
            print(error)
        }
    }
    
    private func _executeInBackground() {
        
        let queue = DatabaseQueue(path: self.databasePath() ?? "")
        queue.inTransaction({ (db) -> Bool in
            print(db.databasePath)
            var success: Bool = true
            do {
                for cmd in self.commands {
                    try cmd.execute(with: db)
                }
            } catch {
                print(error)
                success = false
            }
            return success
        })
    }
}
