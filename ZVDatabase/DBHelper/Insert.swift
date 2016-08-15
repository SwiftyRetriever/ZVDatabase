//
//  Insert.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Insert: Command {

    /**
     <#Description#>
     
     - parameter column:     <#column description#>
     - parameter parameters: <#parameters description#>
     - parameter table:      <#table description#>
     
     - returns: <#return value description#>
     */
    public convenience init(_ column: [String],
                            parameters: [Bindable] = [],
                            into table: String) {
        
        self.init()
        let prefix = column.map { _ in return "?" }
        let sql = "INSERT INTO \(table) (\(column.joined(separator: ", "))) VALUES (\(prefix.joined(separator: ", ")))"
        
        _sql.append(sql)
        _parameters.append(contentsOf: parameters)
    }
    
    /**
     <#Description#>
     
     - parameter values: <#values description#>
     - parameter table:  <#table description#>
     
     - returns: <#return value description#>
     */
    public convenience init(_ values: [String: Bindable],
                            into table: String) {
    
        self.init()
        var columnArray = [String]()
        var prefixArray = [String]()
        var valueArray  = [Bindable]()
        
        for (column, value) in values {
            columnArray.append(column)
            prefixArray.append("?")
            valueArray.append(value)
        }
        
        _sql.append("INSERT INTO \(table) (\(columnArray.joined(separator: ", "))) VALUES (\(prefixArray.joined(separator: ", ")))")
        _parameters.append(contentsOf: valueArray)
    }
}
