//
//  Where.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/10.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Where: Command {

    public convenience init(_ expression: String,
                            parameters: [Bindable] = []) {
        
        self.init()
        _sql.append(expression)
        _parameters.append(contentsOf: parameters)
    }
    
    public convenience init(_ column: String,
                            equalTo value: Bindable,
                            prefix: String = "AND") {
        
        self.init()
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) = \(value)")
    }
    
    public convenience init(_ column: String,
                            unequalTo value: Bindable,
                            prefix: String = "AND") {
        
        self.init()
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) <> \(value)")
    }
    
    public convenience init(_ column: String,
                            lessThan value: Bindable,
                            prefix: String = "AND") {
        
        self.init()
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) <> \(value)")
    }
    
    public convenience init(_ column: String,
                            gatherThan value: Bindable,
                            prefix: String = "AND") {
        
        self.init()
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) <> \(value)")
    }
    
    public convenience init(_ column: String,
                            lessThanOrEqualTo value: Bindable,
                            prefix: String = "AND") {
        
        self.init()
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) <= \(value)")
    }
    
    public convenience init(_ column: String,
                            gatherThanOrEqualTo value: Bindable,
                            prefix: String = "AND") {
        
        self.init()
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) >= \(value)")
    }
    
    public convenience init(_ column: String,
                            between value1: Bindable,
                            and value2: Bindable,
                            prefix: String = "AND") {
        
        self.init()
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) BETWEEN \(value1) AND \(value2)" )
    }
    
    public convenience init(_ column: String,
                            like value: Bindable,
                            prefix: String = "AND") {
        
        self.init()
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) LIKE \(value)" )
    }
    
    public convenience init(_ column: String,
                            in values: [Bindable],
                            prefix: String = "AND") {
        
        self.init()
        let prefix = values.map { _  in return "?" }.joined(separator: ",")
        
        self.add(keyword: "WHERE", prefix: prefix)
        _sql.append("\(column) in \(prefix)")
        _parameters.append(contentsOf: values)
    }
}

//MARK: - AND Statement
public extension Where {
    
    public func and(_ column: String,
                    equalTo value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) = \(value)")
        
        return self
    }
    
    public func and(_ column: String,
                    unequalTo value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <> \(value)")
        
        return self
    }
    
    public func and(_ column: String,
                    lessThan value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <> \(value)")
        
        return self
    }
    
    public func and(_ column: String,
                    gatherThan value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <> \(value)")
        
        return self
    }
    
    public func and(_ column: String,
                    lessThanOrEqualTo value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) <= \(value)")
        
        return self
    }
    
    public func and(_ column: String,
                    gatherThanOrEqualTo value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) >= \(value)")
        
        return self
    }
    
    public func and(_ column: String,
                    between value1: Bindable,
                    and value2: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) BETWEENT \(value1) AND \(value2)" )
        
        return self
    }
    
    public func and(_ column: String,
                    like value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) LIKE \(value)" )
        
        return self
    }
    
    public func and(_ column: String,
                    in values: [Bindable]) -> Where {
        
        let prefix = values.map { _  in return "?" }.joined(separator: ",")
        
        self.add(keyword: "WHERE", prefix: "AND")
        _sql.append("\(column) in \(prefix)")
        _parameters.append(contentsOf: values)
        
        return self
    }
}

//MARK: - OR Statement
public extension Where {
    
    public func or(_ column: String,
                   equalTo value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) = \(value)")
        
        return self
    }
    
    public func or(_ column: String,
                   unequalTo value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) <> \(value)")
        
        return self
    }
    
    public func or(_ column: String,
                   lessThan value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) <> \(value)")
        
        return self
    }
    
    public func or(_ column: String,
                   gatherThan value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) <> \(value)")
        
        return self
    }
    
    public func or(_ column: String,
                   lessThanOrEqualTo value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) <= \(value)")
        
        return self
    }
    
    public func or(_ column: String,
                   gatherThanOrEqualTo value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) >= \(value)")
        
        return self
    }
    
    public func or(_ column: String,
                   between value1: Bindable,
                   and value2: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) BETWEENT \(value1) AND \(value2)" )
        
        return self
    }
    
    public func or(_ column: String,
                   like value: Bindable) -> Where {
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) LIKE \(value)" )
        
        return self
    }
    
    public func or(_ column: String,
                   in values: [Bindable]) -> Where {
        
        let prefix = values.map { _  in return "?" }.joined(separator: ",")
        
        self.add(keyword: "WHERE", prefix: "OR")
        _sql.append("\(column) in \(prefix)")
        _parameters.append(contentsOf: values)
        
        return self
    }
}
