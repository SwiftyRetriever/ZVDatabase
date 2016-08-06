//
//  ZVTableProtocol.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/6.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import Foundation

public protocol ZVTableProtocol {
    
    init()
    
    func databasePath() -> String?
    func tableName() -> String
    func primaryKey() -> String?
    func fields() -> [String: String]
}
