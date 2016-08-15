//
//  Schema.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class Schema: Command {

    /**
     <#Description#>
     
     - parameter table:  <#table description#>
     - parameter fields: <#fields description#>
     
     - returns: <#return value description#>
     */
    public convenience init(create table: String, fields: [String: String]) {
        
        self.init()
        let columns = fields.map { (name, info) -> String in
            return "\(name) \(info)"
        }
        let sql = "CREATE TABLE IF NOT EXISTS \(table) (\(columns.joined(separator: ", ")));"
        _sql.append(sql)
    }
    
    /**
     <#Description#>
     
     - parameter table: <#table description#>
     
     - returns: <#return value description#>
     */
    public convenience init(drop table: String) {
        
        self.init()
        let sql = "DROP TABLE IF NOT EXISTS \(table));"
        _sql.append(sql)
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter info:   <#info description#>
     - parameter table:  <#table description#>
     
     - returns: <#return value description#>
     */
    public convenience init(add column: String, info: String, for table: String) {
        
        self.init()
        let sql = "ALTER TABLE \(table) ADD \(column) \(info);"
        _sql.append(sql)
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter table:  <#table description#>
     
     - returns: <#return value description#>
     */
    public convenience init(delete column: String, from table: String) {
        
        self.init()
        let sql = "ALTER TABLE \(table) DROP COLUMN \(column);"
        _sql.append(sql)
    }
    
    /**
     <#Description#>
     
     - parameter column: <#column description#>
     - parameter info:   <#info description#>
     - parameter table:  <#table description#>
     
     - returns: <#return value description#>
     */
    public convenience init(alert column: String, info: String, for table: String) {
        
        self.init()
        let sql = "ALTER TABLE \(table) ALTER COLUMN \(column) \(info);"
        _sql.append(sql)
    }
}