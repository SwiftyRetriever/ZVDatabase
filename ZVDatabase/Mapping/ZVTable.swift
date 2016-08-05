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
    
    var databasePath: String? { get }
    var tableName: String { get }
    var primaryKey: String? { get }
    var fields: [String: String] { get }
}

public class ZVTable<V: ZVObjectProtocol>: NSObject, ZVTableProtocol {

    internal var dataArray: [Command] = []
    
    public required override init () {}
    
    deinit {}
    
    public var databasePath: String? {
        return nil
    }
    
    public var tableName: String {
        return String(self.classForCoder)
    }
    
    public var primaryKey: String? {
        return nil
    }
    
    public var fields: [String: String] {
        return [:]
    }
    
    public func save(object: ZVObject) {
        let cmd = Command().insert(object.dictionaryValue(), into: self.tableName)
        self.dataArray.append(cmd)
//        try cmd.execute(with: db)
    }
    
    
    public func update(object: ZVObject) {
        
        var values = object.dictionaryValue()
        var primaryKey: Bindable = ""

        if let pk = self.primaryKey {
            
            primaryKey = values[pk]!
            values.removeValue(forKey: pk)
            
            let cmd = Command().update(values, table: self.tableName)
                .where(self.primaryKey!, equalTo: primaryKey)
            self.dataArray.append(cmd)
//            try cmd.execute(with: db)
        } else {
            print("the primary key is not figure out.")
        }
    }
    
    public func delete(by command: Command) {
        
        let cmd = Command().delete(from: self.tableName).append(command: command)
        self.dataArray.append(cmd)
    }
    
    public func select(by command: Command) {
//        let cmd = Command().select(<#T##column: [String]##[String]#>, from: <#T##String#>)
    }
}
