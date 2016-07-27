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


internal enum ColumnType: Int {
    
    case Integer
    case Float
    case Text
    case Blob
    case Null
    
    static func fromSQLiteColumnType(columnType: Int32) -> ColumnType {
        switch columnType {
        case SQLITE_INTEGER:
            return .Integer
        case SQLITE_TEXT, SQLITE3_TEXT:
            return .Text
        case SQLITE_NULL:
            return .Null
        case SQLITE_FLOAT:
            return .Float
        case SQLITE_BLOB:
            return .Blob
        default:
            return .Text
        }
    }

}

public final class Statement: NSObject {
    
    private var _statement: SQLiteParameter? = nil
    private var _sql: UnsafePointer<Int8>? = nil
    private var _db: Connection? = nil
    private var _parameters = [Bindable]()
    
    override init() {
        super.init()
    }
    
    internal convenience init(_ db: Connection, sql: UnsafePointer<Int8>?, parameters: [Bindable]) throws {
        self.init()
        
        _sql = sql
        _db = db
        _parameters = parameters
        
        try self.prepare()
    }
    
    deinit {

    }
    
    private func prepare() throws {
        
        let errCode = sqlite3_prepare(_db!.connection, _sql, -1, &_statement, nil)
        
        guard errCode.isSuccess else {
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
        
        guard errCode.isSuccess else {
            let errMsg = "excute sql \(String(cString: _sql!)), \(_db?.lastErrorMsg)"
            throw DatabaseError.error(code: errCode, msg: errMsg)
        }
    }
    
    internal func query() throws -> [[String: AnyObject]] {
        
        defer {
            sqlite3_finalize(_statement)
        }
        
        var result = sqlite3_step(_statement)
        var rows = [[String: AnyObject]]()
        while result.next {
            rows.append(self.rowValue)
            result = sqlite3_step(_statement)
        }
        return rows
    }
}

//MARK: - Bindable
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
    
    private func _check(_ errCode: CInt, value: AnyObject, index: Int) throws {
        
        guard errCode.isSuccess else {
            let errMsg = "sqlite bind value: \(value) error at \(index) . error code : \(errCode)"
            throw DatabaseError.error(code: errCode, msg: errMsg)
        }
    }
}

//MARL: - RowValue
internal extension Statement {
    
    internal var rowValue: [String: AnyObject] {
        var row = [String: AnyObject]()
        for index in 0 ..< self.columnCount() {
            let columnName = self.columnName(at: index)
            row[columnName] = value(at: index)
        }
        return row
    }
    
    internal func columnCount() -> CInt {
        return sqlite3_column_count(_statement)
    }
    
    internal func columntType(at index: CInt) -> ColumnType {

        let columnType = sqlite3_column_type(_statement, index)
        return ColumnType.fromSQLiteColumnType(columnType: columnType)
    }
    
    internal func columnName(at index: CInt) -> String {
        return String(cString: sqlite3_column_name(_statement, index))
    }

    internal func intValue(at index: CInt) -> Int {
        return Int(sqlite3_column_int64(_statement, index))
    }
    
    internal func doubleValue(at index: CInt) -> Double {
        return sqlite3_column_double(_statement, index)
    }
    
    internal func stringValue(at index: CInt) -> String? {
        return String(cString: UnsafePointer(sqlite3_column_text(_statement, index)))
    }
    
    internal func dataValue(at index: CInt) -> NSData {
        
        let bytes = sqlite3_column_blob(_statement, index)
        let length = sqlite3_column_bytes(_statement, index)
        return NSData(bytes: bytes, length: Int(length))
    }
    
    internal func value(at index: CInt) -> AnyObject? {
        
        switch columntType(at: index) {
        case .Integer:
            return intValue(at: index)
        case .Text:
            return stringValue(at: index)
        case .Float:
            return doubleValue(at: index)
        case .Blob:
            return dataValue(at: index)
        case .Null:
            return nil
        }
    }
}
