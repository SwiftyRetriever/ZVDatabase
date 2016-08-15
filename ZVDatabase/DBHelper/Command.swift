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
    
    /**
     <#Description#>
     
     - parameter expression: <#expression description#>
     - parameter parameters: <#parameters description#>
     - parameter prefix:     <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ expression: String,
                        parameters: [Bindable] = [],
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append(expression)
        _parameters.append(contentsOf: parameters)
        
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter value:  <#value description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        equalTo value: Bindable,
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) = \(value)")
        
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter value:  <#value description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        unequalTo value: Bindable,
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) <> \(value)")
        
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter value:  <#value description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        lessThan value: Bindable,
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) < \(value)")
        
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter value:  <#value description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        gatherThan value: Bindable,
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) > \(value)")
        
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter value:  <#value description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        lessThanOrEqualTo value: Bindable,
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) <= \(value)")
        
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter value:  <#value description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        gatherThanOrEqualTo value: Bindable,
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) >= \(value)")
        
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter value1: <#value1 description#>
     - parameter value2: <#value2 description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        between value1: Bindable,
                        and value2: Bindable,
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) BETWEENT \(value1) AND \(value2)" )
        
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter value:  <#value description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        like value: Bindable,
                        prefix: String = "AND") -> Command {
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) LIKE \(value)" )
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter values: <#values description#>
     - parameter prefix: <#prefix description#>
     
     - returns: <#return value description#>
     */
    public func `where`(_ column: String,
                        in values: [Bindable],
                        prefix: String = "AND") -> Command {
        
        let prefix = values.map { _  in return "?" }.joined(separator: ",")
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) in \(prefix)")
        _parameters.append(contentsOf: values)
        return self
    }
}

//MARK: - Order Statement
public extension Command {
    
    /**
     <#Description#>
     
     - parameter condition: <#condition description#>
     
     - returns: <#return value description#>
     */
    public func order(by condition: [String]) -> Command {
        
        self.add(keyword: "ORDER BY")
        _sql.append(condition.joined(separator: ","))
        return self
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter asc:    <#asc description#>
     
     - returns: <#return value description#>
     */
    public func order(by column: String, asc: Bool = true) -> Command {
        
        self.add(keyword: "ORDER BY")
        _sql.append("\(column) \(asc ? "ASC" : "DESC")")
        return self
    }
}

//MARK: - Appding
public extension Command {
    
    /**
     <#Description#>
     
     - parameter command: <#command description#>
     
     - returns: <#return value description#>
     */
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
    
    /**
     <#Description#>
     
     - returns: <#return value description#>
     */
    public func end() -> Command{
        
        _sql.append(";")
        return self
    }
}

// MARK: - private methods
internal extension Command {
    
    /**
     <#Description#>
     
     - parameter keyword: <#keyword description#>
     - parameter prefix:  <#prefix description#>
     */
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
    
    /**
     <#Description#>
     
     - parameter db: <#db description#>
     
     - throws: <#throws value description#>
     */
    public func execute(with db: Connection) throws {
        
        try db.executeUpdate(_sql, parameters: _parameters)
        
        _sql = ""
        _parameters.removeAll()
    }
    
    /**
     <#Description#>
     
     - parameter db: <#db description#>
     
     - throws: <#throws value description#>
     
     - returns: <#return value description#>
     */
    public func query(with db: Connection) throws -> [[String: AnyObject]] {
        
        let results = try db.executeQuery(_sql, parameters: _parameters)
        
        _sql = ""
        _parameters.removeAll()
        
        return results
    }
}
