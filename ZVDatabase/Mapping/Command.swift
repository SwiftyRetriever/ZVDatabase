//
//  Command.swift
//  ZVDatabase
//
//  Created by ZERO on 16/7/27.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Command: NSObject {
    
    private var _sql: String = ""
    private var _parameters = [Bindable]()
    
    public func select(_ column: [String], from table: String, parameters: [Bindable] = []) -> Command {
        
        let sql = "SELECT \(column.joined(separator: ", ")) FROM \(table)"
        _sql.append(sql)
        _parameters.append(contentsOf: parameters)
        
        return self
    }
    
    public func update(_ column: [String], table: String, parameters: [Bindable] = []) -> Command {
        
        let col = column.map { (col) in return "\(col) = ?" }.joined(separator: ", ")
        let sql = "UPDATE \(table) SET \(col)"
        _sql.append(sql)
        
        return self
    }
    
    public func insert(_ column: [String], into table: String, parameters: [Bindable] = []) -> Command {
        
        let prefix = column.map { _ in return "?" }
        let sql = "INSERT INTO \(table) (\(column.joined(separator: ", "))) VALUES (\(prefix.joined(separator: ", ")))"
        _sql.append(sql)
        
        return self
    }
    
    public func delete(from table: String) -> Command {
        
        let sql = "DELETE FROM \(table)"
        _sql.append(sql)
        
        return self
    }
    
    public func `where`(_ expression: String, parameters: [Bindable] = []) -> Command {
        
        _sql.append(" WHERE ")
        _sql.append(expression)
        _parameters.append(contentsOf: parameters)
        
        return self
    }
    
    public func end() -> Command{
        
        _sql.append(";")
        
        return self
    }
}
