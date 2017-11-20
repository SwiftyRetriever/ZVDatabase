//
//  ZVDatabaseError.swift
//  ZVDatabase
//
//  Created by ZERO on 16/7/2.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import Foundation

#if os(OSX)
    import SQLiteMacOS
#elseif os(iOS)
    #if (arch(i386) || arch(x86_64))
        import SQLiteiPhoneSimulator
    #else
        import SQLiteiPhoneOS
    #endif
#endif

// MARK: - Public
public enum TransactionType {
    case immediate
    case exclusive
    case deferred
}

public typealias SQLite3 = OpaquePointer
public typealias SQLiteParameter = OpaquePointer

// MARK: - Internal
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
internal let SQLITE_STATIC    = unsafeBitCast( 0, to: sqlite3_destructor_type.self)

internal let SQLITE_BIND_COUNT_ERR: Int32 = 1101

internal enum DatabaseError : Error {
    
    case error(code: Int32, msg: String)
}

internal typealias BusyHandler = ((UnsafeMutableRawPointer, Int32) -> Int32)!

internal extension Int32 {

    var isSuccess: Bool {
        
        switch self {
        case SQLITE_OK: return true
        case SQLITE_DONE: return true
        case SQLITE_ROW: return true
        default: return false
        }
    }
    
    var next: Bool {
        
        switch self {
        case SQLITE_DONE: return false
        case SQLITE_ROW: return true
        default: return false
        }
    }
}
