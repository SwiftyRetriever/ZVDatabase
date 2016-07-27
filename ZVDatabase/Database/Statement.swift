//
//  ZVStatement.swift
//  ZVAddressBook
//
//  Created by zevwings on 6/29/16.
//  Copyright © 2016 小零心语. All rights reserved.
//

import UIKit

#if os(OSX)
    import SQLiteMacOS
#elseif os(iOS)
    #if (arch(i386) || arch(x86_64))
        import SQLiteiPhoneSimulator
    #else
        import SQLiteiPhoneOS
    #endif
#endif


public final class Statement: NSObject {
    
    private var _statement: SQLiteParameter? = nil
    private var _sql: UnsafePointer<Int8>? = nil
    private var _db: Connection? = nil
    private var _parameters = [Binding]()
    
    internal init(_ db: Connection, sql: UnsafePointer<Int8>?, parameters: [Binding]) {
        
        _sql = sql
        _db = db
        _parameters = parameters
    }
    
    deinit {

    }
    
    internal func prepare() throws {
        
        let errCode = sqlite3_prepare(_db!.connection, _sql, -1, &_statement, nil)
        
        guard errCode == SQLITE_OK else {
            sqlite3_finalize(_statement)
            let errMsg = "sqlite3_prepare error :\(_db?.lastErrorMsg)"
            throw DatabaseError.error(code: errCode, msg: errMsg)
        }
        
        let count = sqlite3_bind_parameter_count(_statement)
        
        guard count == CInt(_parameters.count) else {
            let errMsg = "failed to bind parameters, counts did not match. SQL: \(_sql), Parameters: \(_parameters)"
            throw DatabaseError.error(code: SQLITE_BIND_COUNT_ERR, msg: errMsg)
        }
        
        if _parameters.count < 1 { return }
        
        for idx in 1 ... _parameters.count {
            
            let value = _parameters[idx - 1]
            try value.bind(to: self, at: idx)
        }
    }
    
    internal func execute() throws {
        
        defer {
            sqlite3_finalize(_statement)
        }
        
        let errCode = sqlite3_step(_statement)
        
        guard errCode == SQLITE_OK || errCode == SQLITE_DONE else {
            let errMsg = "excute sql \(String(cString: _sql!)), \(_db?.lastErrorMsg)"
            throw DatabaseError.error(code: errCode, msg: errMsg)
        }
    }
    
    internal func query() throws -> [ZVSQLRow] {
        
        defer {
            sqlite3_finalize(_statement)
        }
        
        var result = sqlite3_step(_statement)
        var rows = [ZVSQLRow]()
        while result == SQLITE_ROW {
            let count = sqlite3_column_count(_statement)
            rows.append(getRowValue(count: count))
            result = sqlite3_step(_statement)
        }
        
        return rows
    }
    
    internal func getRowValue(count: Int32) -> ZVSQLRow {
        
        let row = ZVSQLRow()
        
        for idx in 0 ..< count {
            
            var column: ZVSQLColumn?
            
            let columnType  = sqlite3_column_type(_statement, idx)
            switch columnType {
            case SQLITE_INTEGER:
                let val = Int(sqlite3_column_int64(_statement, idx))
                column = ZVSQLColumn(value: val, type: columnType)
                break
            case SQLITE_FLOAT:
                let val = Double(sqlite3_column_double(_statement, idx))
                column = ZVSQLColumn(value: val, type: columnType)
                break
            case SQLITE_BLOB:
                let bytes = sqlite3_column_blob(_statement, idx)
                let length = sqlite3_column_bytes(_statement, idx)
                let data = NSData(bytes: bytes, length: Int(length))
                column = ZVSQLColumn(value: data, type: columnType)
                break
            case SQLITE_NULL:
                column = ZVSQLColumn(value: nil, type: columnType)
                break
            case SQLITE_TEXT, SQLITE3_TEXT:
                let val = String(cString: UnsafePointer(sqlite3_column_text(_statement, idx))) ?? ""
                column = ZVSQLColumn(value: val, type: columnType)
                break
            default:
                break
            }
            let key = String(cString: sqlite3_column_name(_statement, idx))
            row[key] = column
        }
        return row
    }
    
    internal func query(forDictionary: Bool) throws -> [[String: AnyObject?]] {
        
        defer {
            sqlite3_finalize(_statement)
        }
        
        var result = sqlite3_step(_statement)
        var rows = [[String: AnyObject?]]()
        while result == SQLITE_ROW {
            let count = sqlite3_column_count(_statement)
            rows.append(getRowValue(forDictionary: count))
            result = sqlite3_step(_statement)
        }
        
        return rows
    }
    
    internal func getRowValue(forDictionary count: Int32) -> [String: AnyObject?] {
        
        var row = [String: AnyObject?]()
        
        for idx in 0 ..< count {
            
            var column: AnyObject?
            
            let columnType  = sqlite3_column_type(_statement, idx)
            switch columnType {
            case SQLITE_INTEGER:
                column = Int(sqlite3_column_int64(_statement, idx))
                break
            case SQLITE_FLOAT:
                column = Double(sqlite3_column_double(_statement, idx))
                break
            case SQLITE_BLOB:
                let bytes = sqlite3_column_blob(_statement, idx)
                let length = sqlite3_column_bytes(_statement, idx)
                column = NSData(bytes: bytes, length: Int(length))
                break
            case SQLITE_NULL:
                column = nil
                break
            case SQLITE_TEXT, SQLITE3_TEXT:
                column = String(cString: UnsafePointer(sqlite3_column_text(_statement, idx))) ?? ""
                break
            default:
                break
            }
            let key = String(cString: sqlite3_column_name(_statement, idx))
            row.updateValue(column, forKey: key)
        }
        return row
    }
}

internal extension Statement {
    
    internal func bind(nullValueAt index: Int) throws {
        
        let errCode = sqlite3_bind_null(_statement, CInt(index))
        try _check(errCode, value: "null", index: index)
    }
    
    internal func bind(intValue value: Int, at index: Int) throws {
        
        let errCode = sqlite3_bind_int(_statement, CInt(index), Int32(value))
        try _check(errCode, value: value, index: index)
    }
    
    internal func bind(int64Value value: Int64, at index: Int) throws {
        
        let errCode = sqlite3_bind_int64(_statement, CInt(index), value)
        try _check(errCode, value: Int(value), index: index)
    }
    
    internal func bind(doubleValue value: Double, at index: Int) throws {
        
        let errCode = sqlite3_bind_double(_statement, CInt(index), value)
        try _check(errCode, value: value, index: index)
    }
    
    internal func bind(dataValue value: NSData, at index: Int) throws {
        var errCode: CInt = 0
        if value.length == 0 {
            errCode = sqlite3_bind_zeroblob(_statement, Int32(index), 0);
        } else {
            errCode = sqlite3_bind_blob(_statement, CInt(index), value.bytes, Int32(value.length), SQLITE_TRANSIENT)
        }
        try _check(errCode, value: value, index: index)
    }
    
    internal func bind(textValue value: String, at index: Int) throws {
    
        let errCode = sqlite3_bind_text(_statement, CInt(index), value, -1, SQLITE_TRANSIENT)
        try _check(errCode, value: value, index: index)
    }
    
    private func _check(_ errorCode: CInt, value: AnyObject, index: Int) throws {
        
        guard errorCode == SQLITE_OK else {
            let errMsg = "sqlite bind value: \(value) error at \(index) . errorCode : \(errorCode)"
            throw DatabaseError.error(code: errorCode, msg: errMsg)
        }
    }
}
