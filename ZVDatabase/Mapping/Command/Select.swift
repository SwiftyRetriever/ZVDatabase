//
//  Select.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

class Select: Command {

    convenience init(_ column: [String], from table: String, parameters: [Bindable] = []) {
        
        self.init()
        let sql = "SELECT \(column.joined(separator: ", ")) FROM \(table)"
        _sql.append(sql)
        _parameters.append(contentsOf: parameters)
    }
}
