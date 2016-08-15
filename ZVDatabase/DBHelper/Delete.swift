//
//  Delete.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Delete: Command {

    /**
     <#Description#>
     
     - parameter table: <#table description#>
     
     - returns: <#return value description#>
     */
    public convenience init(from table: String) {
        self.init()
        let sql = "DELETE FROM \(table)"
        _sql.append(sql)
    }
}
