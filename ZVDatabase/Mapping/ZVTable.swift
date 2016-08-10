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
    
    public func update(_ values: [String: Bindable], where command: Command) {
        
        let cmd = Command().update(values, table: self.tableName()).append(command: command)
        self.commands.append(cmd)
    }
    
    public func delete(by command: Command) {
        
        let cmd = Command().delete(from: self.tableName()).append(command: command)
        self.commands.append(cmd)
    }
    
    public func select(_ rows: [String] = [], by command: Command) {
        
        var cmd: Command!
        if rows.isEmpty {
            let fields = self.shared.fields().map({ (key, _) in return key })
            cmd = Command().select(fields, from: self.tableName()).append(command: command)
        } else {
            cmd = Command().select(rows, from: self.tableName()).append(command: command)
        }
        self.commands.append(cmd)
    }
}
