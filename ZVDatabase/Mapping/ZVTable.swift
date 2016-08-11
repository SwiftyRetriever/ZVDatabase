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

public class ZVTable<V: ZVObject>: NSObject, ZVTableProtocol {

    internal var commands: [Command] = []
    
    public required override init () {}
    
    deinit {}
    
    public func databasePath() -> String? {
        return nil
    }
    
    public func tableName() -> String {
        return String(V.self)
    }
    
    public func primaryKey() -> String? {
        return nil
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
    
    // MARK: - Schema
    public func create() {
        
        let cmd = Command().create(table: self.tableName(), fields: self.shared.fields())
        self.commands.append(cmd)
    }
    
    public func drop() {
        
        let cmd = Command().drop(table: self.tableName())
        self.commands.append(cmd)
    }
    
    public func add(column: String, info: String) {
        
        let cmd = Command().add(column: column, info: info, for: self.tableName())
        self.commands.append(cmd)
    }
    
    public func delete(colmun column: String) {
        
        let cmd = Command().delete(colmun: column, from: self.tableName())
        self.commands.append(cmd)
    }
    
    public func alert(column: String, info: String) {
        
        let cmd = Command().alert(column: column, info: info, for: self.tableName())
        self.commands.append(cmd)
    }

    // MARK: - CRUD
    public func insert(_ object: ZVObject) {
        
        let cmd = Command().insert(object.dictionaryValue(), into: self.tableName())
        self.commands.append(cmd)
    }
    
    public func insert(_ column: [String], parameters: [Bindable] = []) {
        
        let cmd = Command().insert(column, parameters: parameters, into: self.tableName())
        self.commands.append(cmd)
    }
    
    public func update(object: ZVObject) {
        
        var values = object.dictionaryValue()
        var primaryKey: Bindable = ""

        if let pk = self.primaryKey() {
            
            primaryKey = values[pk]!
            values.removeValue(forKey: pk)
            
            let cmd = Command().update(values, table: self.tableName())
                .where(self.primaryKey()!, equalTo: primaryKey)
            self.commands.append(cmd)
        } else {
            print("the primary key is not figure out.")
        }
    }
    
    public func update(_ values: [String: Bindable], where command: Where? = nil) {
        
        var cmd: Command!
        if command == nil {
            cmd = Command().update(values, table: self.tableName())
        } else {
            cmd = Command().update(values, table: self.tableName()).append(command: command!)
        }
        self.commands.append(cmd)
    }
    
    public func delete(where command: Where? = nil) {
        
        var cmd: Command!
        if command == nil {
            cmd = Command().delete(from: self.tableName())
        } else {
            cmd = Command().delete(from: self.tableName()).append(command: command!)
        }
        self.commands.append(cmd)
    }
    
    public func select(_ rows: [String] = [], where command: Where? = nil) {
        
        let fields = rows.isEmpty ? self.shared.fields().map({ (key, _) in return key }) : rows
        var cmd: Command!
        
        if command == nil {
            cmd = Command().select(fields, from: self.tableName())
        } else {
            cmd = Command().select(fields, from: self.tableName()).append(command: command!)
        }
        
        self.commands.append(cmd)
    }
    
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
