//
//  ZVElement+Binding.swift
//  ZVAddressBook
//
//  Created by zevwings on 7/4/16.
//  Copyright © 2016 小零心语. All rights reserved.
//

import Foundation

#if (arch(i386) || arch(x86_64))
    import SQLiteiPhoneSimulator
#else
    import SQLiteiPhoneOS
#endif

//MARK: - binding methods

extension ZVSQLColumn {
    
    internal func bind(_ value: AnyObject?, at index: Int) throws {

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
        }
    }
    
    private func _bind(nullValueAt index: CInt) throws {
        
        let errCode = sqlite3_bind_null(statement, index)
        try _check(errCode, value: "null", index: index)
    }
    
    private func _bind(intValue: AnyObject, at index: CInt) throws {
        
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
        try _check(errCode, value: intValue, index: index)
    }
    
    private func _bind(doubleValue: AnyObject, at index: CInt) throws {
        var errCode: CInt = 0
        
        if let val = doubleValue as? NSNumber {
            errCode = sqlite3_bind_double(statement, index, val.doubleValue)
        }
        try _check(errCode, value: doubleValue, index: index)
    }
    
    private func _bind(booleanValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = booleanValue as? NSNumber {
            errCode = sqlite3_bind_int(statement, index, val.int32Value)
        }
        try _check(errCode, value: booleanValue, index: index)
    }
    
    private func _bind(dateValue: AnyObject, at index: CInt) throws {
        
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
    
    private func _bind(dataValue: AnyObject, at index: CInt) throws {
        
        var errCode: CInt = 0
        
        if let val = dataValue as? NSData {
            errCode = sqlite3_bind_blob(statement, index, val.bytes, Int32(val.length), SQLITE_TRANSIENT)
        }
        try _check(errCode, value: dataValue, index: index)
    }
    
    private func _bind(textValue: AnyObject, at index: CInt) throws {
        
        let val = String(textValue)
        
        let errCode = sqlite3_bind_text(statement, index, val, -1 , SQLITE_TRANSIENT)
        try _check(errCode, value: textValue, index: index)
    }
    
    private func _check(_ errorCode: CInt, value: AnyObject, index: CInt) throws {
        
        guard errorCode == SQLITE_OK else {
            let errMsg = "sqlite bind value: \(value) error at \(index) . errorCode : \(errorCode)"
            throw ZVDatabaseError.error(code: errorCode, msg: errMsg)
        }
    }
}
