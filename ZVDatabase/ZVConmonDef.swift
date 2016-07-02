//
//  ZVDatabaseError.swift
//  ZVDatabase
//
//  Created by ZERO on 16/7/2.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import Foundation

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

let SQLITE_BIND_COUNT_ERR: Int32 = 1101

internal func ZVLog(_ items: Swift.Any..., separator: String = "", terminator: String = "") {
    print(items, separator: separator, terminator: terminator)
}

public enum ZVDatabaseError : ErrorProtocol {
    
    case error(code: Int32, msg: String)
    
}
