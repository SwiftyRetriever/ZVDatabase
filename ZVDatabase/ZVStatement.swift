//
//  ZVStatement.swift
//  ZVAddressBook
//
//  Created by zevwings on 6/29/16.
//  Copyright © 2016 小零心语. All rights reserved.
//

import UIKit

#if (arch(i386) || arch(x86_64))
    import SQLiteiPhoneSimulator
#else
    import SQLiteiPhoneOS
#endif

internal final class ZVStatement {
    
    private var statement: OpaquePointer? = nil
    private var sql: UnsafePointer<Int8>? = nil
    private var db: ZVConnection? = nil
    private var parameters: [AnyObject?]?
    
    internal init(_ db: ZVConnection, sql: UnsafePointer<Int8>?, parameters: [AnyObject?]?) {
        
        self.sql = sql
        self.db = db
        self.parameters = parameters
    }
    
    deinit {
        sql = nil
        db = nil
        parameters = nil
    }
    
    internal func prepare() throws {
        
        let errCode = sqlite3_prepare(db!.connection, sql, -1, &statement, nil)
        
        guard errCode == SQLITE_OK else {
            sqlite3_finalize(statement)
            let errMsg = "sqlite3_prepare error :\(db?.lastErrorMsg)"
            throw ZVDatabaseError.error(code: errCode, msg: errMsg)
        }
        
        if let params = parameters {
            
            let count = sqlite3_bind_parameter_count(statement)
            
            guard count == CInt(params.count) else {
                let errMsg = "failed to bind parameters, counts did not match. SQL: \(sql), Parameters: \(params)"
                throw ZVDatabaseError.error(code: SQLITE_BIND_COUNT_ERR, msg: errMsg)
            }
            
            for idx in 1...params.count {
                
                let val = params[idx - 1]
                try ZVSQLColumn(statement: statement).bind(val, at: idx)
            }
        }
    }
    
    internal func execute() throws {
        
        defer {
            sqlite3_finalize(statement)
        }
        
        let errCode = sqlite3_step(statement)
        
        guard errCode == SQLITE_OK || errCode == SQLITE_DONE else {
            let errMsg = "excute sql \(String(cString: sql!)), \(self.db?.lastErrorMsg)"
            throw ZVDatabaseError.error(code: errCode, msg: errMsg)
        }
    }
    
    internal func query() throws -> [ZVSQLRow] {
        
        defer {
            sqlite3_finalize(statement)
        }
        
        var result = sqlite3_step(statement)
        var rows = [ZVSQLRow]()
        while result == SQLITE_ROW {
            let count = sqlite3_column_count(statement)
            rows.append(getRowValue(count: count))
            result = sqlite3_step(statement)
        }
        
        return rows
    }
    
    internal func getRowValue(count: Int32) -> ZVSQLRow {
        
        let row = ZVSQLRow()
        
        for idx in 0 ..< count {
            
            var column: ZVSQLColumn?
            
            let columnType  = sqlite3_column_type(statement, idx)
            switch columnType {
            case SQLITE_INTEGER:
                let val = Int(sqlite3_column_int64(statement, idx))
                column = ZVSQLColumn(value: val, type: columnType)
                break
            case SQLITE_FLOAT:
                let val = Double(sqlite3_column_double(statement, idx))
                column = ZVSQLColumn(value: val, type: columnType)
                break
            case SQLITE_BLOB:
                let bytes = sqlite3_column_blob(statement, idx)
                let length = sqlite3_column_bytes(statement, idx)
                let data = NSData(bytes: bytes, length: Int(length))
                column = ZVSQLColumn(value: data, type: columnType)
                break
            case SQLITE_NULL:
                column = ZVSQLColumn(value: nil, type: columnType)
                break
            case SQLITE_TEXT, SQLITE3_TEXT:
                let val = String(cString: UnsafePointer(sqlite3_column_text(statement, idx))) ?? ""
                column = ZVSQLColumn(value: val, type: columnType)
                break
            default:
                break
            }
            let key = String(cString: sqlite3_column_name(statement, idx))
            row[key] = column
        }
        return row
    }
    
    internal func query(forDictionary: Bool) throws -> [[String: AnyObject?]] {
        
        defer {
            sqlite3_finalize(statement)
        }
        
        var result = sqlite3_step(statement)
        var rows = [[String: AnyObject?]]()
        while result == SQLITE_ROW {
            let count = sqlite3_column_count(statement)
            rows.append(getRowValue(forDictionary: count))
            result = sqlite3_step(statement)
        }
        
        return rows
    }
    
    internal func getRowValue(forDictionary count: Int32) -> [String: AnyObject?] {
        
        var row = [String: AnyObject?]()
        
        for idx in 0 ..< count {
            
            var column: AnyObject?
            
            let columnType  = sqlite3_column_type(statement, idx)
            switch columnType {
            case SQLITE_INTEGER:
                column = Int(sqlite3_column_int64(statement, idx))
                break
            case SQLITE_FLOAT:
                column = Double(sqlite3_column_double(statement, idx))
                break
            case SQLITE_BLOB:
                let bytes = sqlite3_column_blob(statement, idx)
                let length = sqlite3_column_bytes(statement, idx)
                column = NSData(bytes: bytes, length: Int(length))
                break
            case SQLITE_NULL:
                column = nil
                break
            case SQLITE_TEXT, SQLITE3_TEXT:
                column = String(cString: UnsafePointer(sqlite3_column_text(statement, idx))) ?? ""
                break
            default:
                break
            }
            let key = String(cString: sqlite3_column_name(statement, idx))
            row.updateValue(column, forKey: key)
        }
        return row
    }
}
