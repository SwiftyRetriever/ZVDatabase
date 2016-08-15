//
//  Order.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Order: Command {

    /**
     <#Description#>
     
     - parameter condition: <#condition description#>
     
     - returns: <#return value description#>
     */
    public convenience init(condition: [String]) {
        
        self.init()
        self.add(keyword: "ORDER BY")
        _sql.append(condition.joined(separator: ","))
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter asc:    <#asc description#>
     
     - returns: <#return value description#>
     */
    public convenience init(column: String, asc: Bool = true) {
        
        self.init()
        self.add(keyword: "ORDER BY")
        _sql.append("\(column) \(asc ? "ASC" : "DESC")")
    }
}
