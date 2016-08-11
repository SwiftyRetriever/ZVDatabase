//
//  Update.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

class Update: Command {

    convenience init(_ column: [String], table: String, parameters: [Bindable] = []) {
        
        self.init()
        let col = column.map { (col) in return "\(col) = ?" }.joined(separator: ", ")
        _sql.append("UPDATE \(table) SET \(col)")
        _parameters.append(contentsOf: parameters)
    }
    
    convenience init(_ values: [String: Bindable], table: String) {
    
        self.init()
        var columnArray = [String]()
        var valueArray  = [Bindable]()
        
        for (column, value) in values {
            columnArray.append("\(column) = ?")
            valueArray.append(value)
        }
        
        _sql.append("UPDATE \(table) SET \(columnArray.joined(separator: ","))")
        _parameters.append(contentsOf: valueArray)
    }
}
