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
    
    public override init() {}
    deinit {}

    //MARK: - CRUD
    public func insert(_ column: [String], into table: String, parameters: [Bindable] = []) -> Command {
        
        let prefix = column.map { _ in return "?" }
        let sql = "INSERT INTO \(table) (\(column.joined(separator: ", "))) VALUES (\(prefix.joined(separator: ", ")))"
        
        _sql.append(sql)
        _parameters.append(contentsOf: parameters)
        
        return self
    }
    
    public func insert(_ values: [String: Bindable], into table: String) -> Command {
        
        var columnArray = [String]()
        var prefixArray = [String]()
        var valueArray  = [Bindable]()
        
        for (column, value) in values {
            columnArray.append(column)
            prefixArray.append(",")
            valueArray.append(value)
        }
        
        _sql.append("INSERT INTO \(table) \(columnArray.joined(separator: ",")) VALUES (\(prefixArray.joined(separator: ", ")))")
        _parameters.append(contentsOf: valueArray)
        
        return self
    }
    
    public func update(_ column: [String], table: String, parameters: [Bindable] = []) -> Command {
        
        let col = column.map { (col) in return "\(col) = ?" }.joined(separator: ", ")
        _sql.append("UPDATE \(table) SET \(col)")
        _parameters.append(contentsOf: parameters)
        
        return self
    }
    
    public func update(_ values: [String: Bindable], table: String) -> Command {
        
        var columnArray = [String]()
        var valueArray  = [Bindable]()
        
        for (column, value) in values {
            columnArray.append("\(column) = ?")
            valueArray.append(value)
        }
        
        _sql.append("UPDATE \(table) SET \(columnArray.joined(separator: ","))")
        _parameters.append(contentsOf: valueArray)
        
        return self
    }
    
    public func delete(from table: String) -> Command {
        
        let sql = "DELETE FROM \(table)"
        _sql.append(sql)
        
        return self
    }
    
    public func select(_ column: [String], from table: String, parameters: [Bindable] = []) -> Command {
        
        let sql = "SELECT \(column.joined(separator: ", ")) FROM \(table)"
        _sql.append(sql)
        _parameters.append(contentsOf: parameters)
        
        return self
    }
    
    //MARK: - WHERE Statement
    public func `where`(_ expression: String, parameters: [Bindable] = []) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append(expression)
        _parameters.append(contentsOf: parameters)
        
        return self
    }
    
    public func `where`(_ column: String, equalTo value: Bindable) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) = \(value)")

        return self
    }
    
    public func `where`(_ column: String, unequalTo value: Bindable) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <> \(value)")

        return self
    }
    
    public func `where`(_ column: String, lessThan value: Bindable) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) < \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, gatherThan value: Bindable) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) > \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, lessThanOrEqualTo value: Bindable) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <= \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, gatherThanOrEqualTo value: Bindable) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) >= \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, between value1: Bindable, and value2: Bindable) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) BETWEENT \(value1) AND \(value2)" )
        
        return self
    }
    
    public func `where`(_ column: String, like value: Bindable) -> Command {
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) LIKE \(value)" )
        return self
    }
    
    public func `where`(_ column: String, in values: [Bindable]) -> Command {
        
        let prefix = values.map { _  in return "?" }.joined(separator: ",")
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) in \(prefix)")
        _parameters.append(contentsOf: values)
        return self
    }
    
    //MARK: - ORDER Statement
    public func order(by condition: [String]) -> Command {
        
        _add(keyword: "ORDER BY")
        _sql.append(condition.joined(separator: ","))
        return self
    }
    
    public func order(by column: String, asc: Bool = true) -> Command {
        
        _add(keyword: "ORDER BY")
        _sql.append("\(column) \(asc ? "ASC" : "DESC")")
        return self
    }
    
    // Add End Prefix
    public func end() -> Command{
        
        _sql.append(";")
        return self
    }
    
    //MARK: - Execute
    public func execute(with db: Connection) throws {
    
        try db.executeUpdate(_sql, parameters: _parameters)
        
        _sql = ""
        _parameters.removeAll()
    }
    
    public func query(with db: Connection) throws -> [[String: AnyObject]] {
        
        let results = try db.executeQuery(_sql, parameters: _parameters)
        
        _sql = ""
        _parameters.removeAll()
        
        return results
    }
    
    // MARK: - private methods
    private func _add(keyword: String, prefix: String = ", ") {
        
        if _sql.contains(keyword) {
            _sql.append(" \(prefix) ")
        } else {
            _sql.append(" \(keyword) ")
        }
    }
}
