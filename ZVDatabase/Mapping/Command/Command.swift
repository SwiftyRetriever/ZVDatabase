//
//  Command.swift
//  ZVDatabase
//
//  Created by ZERO on 16/7/27.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Command: NSObject {
    
    internal var _sql: String = ""
    internal var _parameters = [Bindable]()
    
    public override init() {}
    deinit {}
    
    public var isEmpty: Bool {
        
        var isEmpty: Bool = true
        if _sql.isEmpty || _parameters.isEmpty {
            isEmpty = true
        }
        return isEmpty
    }
}

//MARK: - WHERE Statement
public extension Command {
    
    public func `where`(_ expression: String, parameters: [Bindable] = []) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append(expression)
        _parameters.append(contentsOf: parameters)
        
        return self
    }
    
    public func `where`(_ column: String, equalTo value: Bindable) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) = \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, unequalTo value: Bindable) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <> \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, lessThan value: Bindable) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) < \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, gatherThan value: Bindable) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) > \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, lessThanOrEqualTo value: Bindable) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <= \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, gatherThanOrEqualTo value: Bindable) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) >= \(value)")
        
        return self
    }
    
    public func `where`(_ column: String, between value1: Bindable, and value2: Bindable) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) BETWEENT \(value1) AND \(value2)" )
        
        return self
    }
    
    public func `where`(_ column: String, like value: Bindable) -> Command {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) LIKE \(value)" )
        return self
    }
    
    public func `where`(_ column: String, in values: [Bindable]) -> Command {
        
        let prefix = values.map { _  in return "?" }.joined(separator: ",")
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) in \(prefix)")
        _parameters.append(contentsOf: values)
        return self
    }
}

//MARK: - Order Statement
public extension Command {
    
    public func order(by condition: [String]) -> Command {
        
        self.add(keyword: "ORDER BY")
        _sql.append(condition.joined(separator: ","))
        return self
    }
    
    public func order(by column: String, asc: Bool = true) -> Command {
        
        self.add(keyword: "ORDER BY")
        _sql.append("\(column) \(asc ? "ASC" : "DESC")")
        return self
    }
}

//MARK: - Appding
public extension Command {
    
    public func appending(_ command: Command?) -> Command {
        
        if command == nil && command!.isEmpty {
            return self
        }
        
        self._sql.append(command!._sql)
        self._parameters.append(contentsOf: command!._parameters)
        return self
    }
}

//MARK: - End Prefix
public extension Command {
    
    public func end() -> Command{
        
        _sql.append(";")
        return self
    }
}

// MARK: - private methods
internal extension Command {
    
    internal func add(keyword: String, prefix: String = ", ") {
        
        if _sql.contains(keyword) {
            _sql.append(" \(prefix) ")
        } else {
            _sql.append(" \(keyword) ")
        }
    }
}

//MARK: - Execute
public extension Command {
    
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
}
