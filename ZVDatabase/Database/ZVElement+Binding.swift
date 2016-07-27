//
//  ZVElement+Binding.swift
//  ZVAddressBook
//
//  Created by zevwings on 7/4/16.
//  Copyright © 2016 小零心语. All rights reserved.
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


//MARK: - binding methods

extension ZVSQLColumn {
    
    internal func bind(_ value: AnyObject?, at index: Int) throws {
        /*
        let idx = CInt(index)
        
        if let val = value {
            
            switch val {
            case is NSNull:
                try _bind(nullValueAt: idx)
                break
            case is Int8, is UInt8, is Int16, is UInt16, is Int32, is UInt32, is Int64, is UInt64:
                try _bind(intValue: val, at: idx)
                break
                
            case is Float, is Double:
                try _bind(doubleValue: val, at: idx)
                break
            case is Bool, is Boolean:
                try _bind(booleanValue: val, at: idx)
                break
            case is Date, is NSDate:
                try _bind(dateValue: val, at: idx)
                break
            case is String:
                try _bind(textValue: val, at: idx)
                break
            case is Int, is UInt, is NSNumber:
                try _bind(intValue: val, at: idx)
                break
            case is Data:
                try _bind(dataValue: val, at: idx)
                break
            default:
                try _bind(textValue: val, at: idx)
                break
            }
        } else {
            
            try _bind(nullValueAt: idx)
        }*/
    }
    
    internal func bind(nullValueAt index: CInt) throws {
        
        let errCode = sqlite3_bind_null(statement, index)
        try _check(errCode, value: "null", index: index)
    }
    
    internal func bind(intValue: Int, at index: CInt) throws {
        
        let errCode = sqlite3_bind_int(statement, index, Int32(intValue))
        try _check(errCode, value: intValue, index: index)
    }
    
    internal func bind(int64Value: Int, at index: CInt) throws {
        
        let errCode = sqlite3_bind_int64(statement, index, sqlite3_int64(intValue))
        try _check(errCode, value: intValue, index: index)
    }
    
    internal func bind(doubleValue: AnyObject, at index: CInt) throws {
        var errCode: CInt = 0
        
        if let val = doubleValue as? NSNumber {
            errCode = sqlite3_bind_double(statement, index, val.doubleValue)
        }
        try _check(errCode, value: doubleValue, index: index)
    }
    
    internal func bind(booleanValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = booleanValue as? NSNumber {
            errCode = sqlite3_bind_int(statement, index, val.int32Value)
        }
        try _check(errCode, value: booleanValue, index: index)
    }
    
    internal func bind(dateValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = dateValue as? NSDate {
            let timeInterval = val.timeIntervalSince1970
            errCode = sqlite3_bind_double(statement, index, Double(timeInterval))
        } else if let val = dateValue as? Date {
            let timeInterval = val.timeIntervalSince1970
            errCode = sqlite3_bind_double(statement, index, Double(timeInterval))
        }
        try _check(errCode, value: dateValue, index: index)
    }
    
    internal func bind(dataValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = dataValue as? NSData {
            errCode = sqlite3_bind_blob(statement, index, val.bytes, Int32(val.length), SQLITE_TRANSIENT)
        }
        try _check(errCode, value: dataValue, index: index)
    }
    
    internal func bind(textValue: AnyObject, at index: CInt) throws {
        
        let val = String(textValue)
        
        let errCode = sqlite3_bind_text(statement, index, val, -1 , SQLITE_TRANSIENT)
        try _check(errCode, value: textValue, index: index)
    }
    
    private func _check(_ errorCode: CInt, value: AnyObject, index: CInt) throws {
        
        guard errorCode == SQLITE_OK else {
            let errMsg = "sqlite bind value: \(value) error at \(index) . errorCode : \(errorCode)"
            throw DatabaseError.error(code: errorCode, msg: errMsg)
        }
    }
}
