//
//  ZVTable.swift
//  ZVDatabase
//
//  Created by naver on 16/7/28.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public protocol ZVTableProtocol {
    
    init()
    
    func databasePath() -> String?
    func tableName() -> String
    func primaryKey() -> String?
    func fields() -> [String: String]
}

public class ZVTable<V: ZVObjectProtocol>: NSObject, ZVTableProtocol {

    internal var dataArray: [SQL] = []
    
    public required override init () {}
    
    deinit {}
    
    public func databasePath() -> String? {
        return nil
    }
    
    public func tableName() -> String {
        return String(self.classForCoder)
    }
    
    public func primaryKey() -> String? {
        return nil
    }
    
    public func fields() -> [String: String] {
        return [:]
    }
    
    public func create() {
        
        let cmd = SQL().create(table: self.tableName(), fields: self.fields())
        self.dataArray.append(cmd)
    }
    
    public func save(object: ZVObject) {
        
        let cmd = SQL().insert(object.dictionaryValue(), into: self.tableName())
        self.dataArray.append(cmd)
    }
    
    public func update(object: ZVObject) {
        
        var values = object.dictionaryValue()
        var primaryKey: Bindable = ""

        if let pk = self.primaryKey() {
            
            primaryKey = values[pk]!
            values.removeValue(forKey: pk)
            
            let cmd = SQL().update(values, table: self.tableName())
                .where(self.primaryKey()!, equalTo: primaryKey)
            self.dataArray.append(cmd)
        } else {
            print("the primary key is not figure out.")
        }
    }
    
    public func delete(by command: SQL) {
        
        let cmd = SQL().delete(from: self.tableName()).append(command: command)
        self.dataArray.append(cmd)
    }
    
//    public func select(by command: SQL) {
//        let cmd = Command().select(<#T##column: [String]##[String]#>, from: <#T##String#>)
//    }
}
