//
//  ZVStatement.swift
//  ZVAddressBook
//
//  Created by zevwings on 6/29/16.
//  Copyright © 2016 小零心语. All rights reserved.
//

import UIKit
#if arch(i386) || arch(x86_64)
    import SQLite3iPhoneSimulator
#else
    import SQLite3iPhoneOS
#endif

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

let SQLITE_BIND_COUNT_ERR: Int32 = 1101

public final class ZVStatement {
    
    private var statement: OpaquePointer? = nil
    private var sql: UnsafePointer<Int8>? = nil
    private var db: ZVConnection? = nil
    private var parameters: [AnyObject?]?
    
    public init(_ db: ZVConnection, sql: UnsafePointer<Int8>?, parameters: [AnyObject?]?) {
        
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
                try bind(val, at: idx)
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
    
    internal func query() throws -> [ZVRow] {
        
        defer {
            sqlite3_finalize(statement)
        }
        
        var result = sqlite3_step(statement)
        var rows = [ZVRow]()
        while result == SQLITE_ROW {
            let count = sqlite3_column_count(statement)
            rows.append(getRowValue(count: count))
            result = sqlite3_step(statement)
        }
        
        return rows
    }
    
    internal func getRowValue(count: Int32) -> ZVRow {
        
        let row = ZVRow()
        
        for idx in 0 ..< count {
            
            var column: ZVColumn?
            
            let columnType  = sqlite3_column_type(statement, idx)
            switch columnType {
            case SQLITE_INTEGER:
                let val = Int(sqlite3_column_int64(statement, idx))
                column = ZVColumn(value: val, type: columnType)
                break
            case SQLITE_FLOAT:
                let val = Double(sqlite3_column_double(statement, idx))
                column = ZVColumn(value: val, type: columnType)
                break
            case SQLITE_BLOB:
                let bytes = sqlite3_column_blob(statement, idx)
                let length = sqlite3_column_bytes(statement, idx)
                let data = NSData(bytes: bytes, length: Int(length))
                column = ZVColumn(value: data, type: columnType)
                break
            case SQLITE_NULL:
                column = ZVColumn(value: nil, type: columnType)
                break
            case SQLITE_TEXT, SQLITE3_TEXT:
                let val = String(cString: UnsafePointer(sqlite3_column_text(statement, idx))) ?? ""
                column = ZVColumn(value: val, type: columnType)
                break
            default:
                break
            }
            let key = String(cString: sqlite3_column_name(statement, idx))
            row[key] = column
        }
        return row
    }
    
//    SQLITE_API const void *SQLITE_STDCALL sqlite3_column_blob(sqlite3_stmt*, int iCol);
//    SQLITE_API int SQLITE_STDCALL sqlite3_column_bytes(sqlite3_stmt*, int iCol);
//    SQLITE_API int SQLITE_STDCALL sqlite3_column_bytes16(sqlite3_stmt*, int iCol);
//    SQLITE_API double SQLITE_STDCALL sqlite3_column_double(sqlite3_stmt*, int iCol);
//    SQLITE_API int SQLITE_STDCALL sqlite3_column_int(sqlite3_stmt*, int iCol);
//    SQLITE_API sqlite3_int64 SQLITE_STDCALL sqlite3_column_int64(sqlite3_stmt*, int iCol);
//    SQLITE_API const unsigned char *SQLITE_STDCALL sqlite3_column_text(sqlite3_stmt*, int iCol);
//    SQLITE_API const void *SQLITE_STDCALL sqlite3_column_text16(sqlite3_stmt*, int iCol);
//    SQLITE_API int SQLITE_STDCALL sqlite3_column_type(sqlite3_stmt*, int iCol);
//    SQLITE_API sqlite3_value *SQLITE_STDCALL sqlite3_column_value(sqlite3_stmt*, int iCol);

    
}

//MARK: - binding methods

extension ZVStatement {
    
    private func bind(_ value: AnyObject?, at index: Int) throws {
        
        let idx = CInt(index)
        
        if let val = value {
            
            switch val {
            case is NSNull:
                try bind(nullValueAt: idx)
                break
            case is Int, is UInt, is Int8, is UInt8, is Int16, is UInt16, is Int32, is UInt32, is Int64, is UInt64:
                try bind(intValue: val, at: idx)
                break
                
            case is Float, is Double:
                try bind(doubleValue: val, at: idx)
                break
            case is Bool, is Boolean:
                try bind(booleanValue: val, at: idx)
                break
            case is Date, is NSDate:
                try bind(dateValue: val, at: idx)
                break
            case is String:
                try bind(textValue: val, at: idx)
                break
            case is NSNumber:
                try bind(intValue: val, at: idx)
                break
            case is Data:
                try bind(dataValue: val, at: idx)
                break
            default:
                try bind(textValue: val, at: idx)
                break
            }
        } else {
            
            try bind(nullValueAt: idx)
        }
    }
    
    private func bind(nullValueAt index: CInt) throws {
        
        let errCode = sqlite3_bind_null(statement, index)
        try check(errCode, value: "null", index: index)
    }
    
    private func bind(intValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = intValue as? NSNumber {
            
            // get the objc type from value and bind to stmt
            let typeEncoding = String(cString: val.objCType)
            
            switch typeEncoding {
            case "c":
                errCode = sqlite3_bind_int(statement, index, Int32(val.int8Value))
                break
            case "s":
                errCode = sqlite3_bind_int(statement, index, Int32(val.int16Value))
                break
            case "i":
                errCode = sqlite3_bind_int(statement, index, val.int32Value)
                break
            case "l":
                errCode = sqlite3_bind_int(statement, index, val.int32Value)
                break
            case "q":
                errCode = sqlite3_bind_int64(statement, index, val.int64Value)
                break
            case "C":
                errCode = sqlite3_bind_int(statement, index, Int32(val.uint8Value))
                break
            case "S":
                errCode = sqlite3_bind_int(statement, index, Int32(val.uint16Value))
                break
            case "I":
                errCode = sqlite3_bind_int64(statement, index, sqlite3_int64(val.uintValue))
                break
            case "L":
                errCode = sqlite3_bind_int64(statement, index, val.int64Value)
                break
            case "Q":
                errCode = sqlite3_bind_int64(statement, index, sqlite3_int64(val.uint64Value))
                break
            default:
                break
            }
        }
        try check(errCode, value: intValue, index: index)
    }
    
    private func bind(doubleValue: AnyObject, at index: CInt) throws {
        var errCode: CInt = 0
        
        if let val = doubleValue as? NSNumber {
            errCode = sqlite3_bind_double(statement, index, val.doubleValue)
        }
        try check(errCode, value: doubleValue, index: index)
    }
    
    private func bind(booleanValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = booleanValue as? NSNumber {
            errCode = sqlite3_bind_int(statement, index, val.int32Value)
        }
        try check(errCode, value: booleanValue, index: index)
    }
    
    private func bind(dateValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = dateValue as? NSDate {
            let timeInterval = val.timeIntervalSince1970
            errCode = sqlite3_bind_double(statement, index, Double(timeInterval))
        } else if let val = dateValue as? Date {
            let timeInterval = val.timeIntervalSince1970
            errCode = sqlite3_bind_double(statement, index, Double(timeInterval))
        }
        try check(errCode, value: dateValue, index: index)
    }
    
    private func bind(dataValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = dataValue as? NSData {
            errCode = sqlite3_bind_blob(statement, index, val.bytes, Int32(val.length), SQLITE_TRANSIENT)
        }
        try check(errCode, value: dataValue, index: index)
    }
    
    private func bind(textValue: AnyObject, at index: CInt) throws {
        
        let val = String(textValue)
        
        let errCode = sqlite3_bind_text(statement, index, val, -1 , SQLITE_TRANSIENT)
        try check(errCode, value: textValue, index: index)
    }
    
    private func check(_ errorCode: CInt, value: AnyObject, index: CInt) throws {
        
        guard errorCode == SQLITE_OK else {
            let errMsg = "sqlite bind value: \(value) error at \(index) . errorCode : \(errorCode)"
            throw ZVDatabaseError.error(code: errorCode, msg: errMsg)
        }
    }
}
