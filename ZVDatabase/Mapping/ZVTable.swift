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
    
    public func save(object: ZVObject, db: Connection) throws {
        let cmd = Command().insert(object.dictionaryValue(), into: self.tableName)
        try cmd.execute(with: db)
    }
    
}
