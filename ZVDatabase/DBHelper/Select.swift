//
//  Select.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Select: Command {

    /**
     <#Description#>
     
     - parameter column:     <#column description#>
     - parameter table:      <#table description#>
     - parameter parameters: <#parameters description#>
     
     - returns: <#return value description#>
     */
    public convenience init(_ column: [String],
                            from table: String,
                            parameters: [Bindable] = []) {
        
        self.init()
        let sql = "SELECT \(column.joined(separator: ", ")) FROM \(table)"
        _sql.append(sql)
        _parameters.append(contentsOf: parameters)
    }
}
