//
//  Where.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/10.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Where: Command {

    private override init() {}
    
    public convenience init(_ expression: String, parameters: [Bindable] = []) {
        self.init()
        _sql.append(expression)
        _parameters.append(contentsOf: parameters)
    }
    
    public convenience init(_ column: String, equalTo value: Bindable) {
        self.init()
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) = \(value)")
    }
    
    public convenience init(_ column: String, unequalTo value: Bindable) {
        self.init()
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <> \(value)")
    }
    
    public convenience init(_ column: String, lessThan value: Bindable) {
        self.init()
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <> \(value)")
    }
    
    public convenience init(_ column: String, gatherThan value: Bindable) {
        self.init()
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <> \(value)")
    }
    
    public convenience init(_ column: String, lessThanOrEqualTo value: Bindable) {
        self.init()
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <= \(value)")
    }
    
    public convenience init(_ column: String, gatherThanOrEqualTo value: Bindable) {
        self.init()
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) >= \(value)")
    }
    
    public convenience init(_ column: String, between value1: Bindable, and value2: Bindable) {
        self.init()
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) BETWEENT \(value1) AND \(value2)" )
    }
    
    public convenience init(_ column: String, like value: Bindable) {
        self.init()
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) LIKE \(value)" )
    }
    
    public convenience init(_ column: String, in values: [Bindable]) {
        
        self.init()
        let prefix = values.map { _  in return "?" }.joined(separator: ",")
        
        _add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) in \(prefix)")
        _parameters.append(contentsOf: values)
    }
}
