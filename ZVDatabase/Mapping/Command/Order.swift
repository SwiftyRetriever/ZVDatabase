//
//  Order.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Order: Command {

    public convenience init(condition: [String]) {
        
        self.init()
        _add(keyword: "ORDER BY")
        _sql.append(condition.joined(separator: ","))
    }
    
    public convenience init(column: String, asc: Bool = true) {
        
        self.init()
        _add(keyword: "ORDER BY")
        _sql.append("\(column) \(asc ? "ASC" : "DESC")")
    }
}
