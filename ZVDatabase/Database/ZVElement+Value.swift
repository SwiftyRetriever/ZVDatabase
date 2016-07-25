//
//  ZVElement+Value.swift
//  ZVAddressBook
//
//  Created by zevwings on 7/4/16.
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


// MARK: - Transform
public extension ZVSQLColumn {
    
    public var numberValue: NSNumber {
        get {
            var decimal = NSNumber(value: 0)
            switch (type) {
            case SQLITE_INTEGER, SQLITE_FLOAT:
                return self.value as? NSNumber ?? NSNumber(value: 0)
                
            case SQLITE_TEXT:
                decimal = NSDecimalNumber(string: self.value as? String)
                if decimal == NSDecimalNumber.notA {
                    decimal = NSDecimalNumber.zero
                }
                
            case SQLITE_BLOB:
                if let val = value as? Data {
                    decimal = NSDecimalNumber(string: String(data: val, encoding: .utf8))
                    if decimal == NSDecimalNumber.notA {
                        decimal = NSDecimalNumber.zero
                    }
                }
                
            default:
                break
            }
            
            return decimal
        }
    }
    
    public var string: String? {
        return String(self.value)
    }
    
    public var stringValue: String {
        if let val = value { return String(val) }
        return ""
    }
    
    public var boolValue: Bool {
        get { return self.numberValue.boolValue }
    }
    
    public var intValue: Int {
        get { return self.numberValue.intValue }
    }
    
    public var uintValue: UInt {
        get { return self.numberValue.uintValue }
    }
    
    public var int8Value: Int8 {
        get { return self.numberValue.int8Value }
    }
    
    public var uint8Value: UInt8 {
        get { return self.numberValue.uint8Value }
    }
    
    public var int16Value: Int16 {
        get { return self.numberValue.int16Value }
    }
    
    public var uint16Value: UInt16 {
        get { return self.numberValue.uint16Value }
    }
    
    public var int32Value: Int32 {
        get { return self.numberValue.int32Value }
    }
    
    public var uint32Value: UInt32 {
        get { return self.numberValue.uint32Value }
    }
    
    public var int64Value: Int64 {
        get { return self.numberValue.int64Value }
    }
    
    public var uint64Value: UInt64 {
        get { return self.numberValue.uint64Value }
    }
    
    public var floatValue: Float {
        get { return self.numberValue.floatValue }
    }
    
    public var doubleValue: Double {
        get { return self.numberValue.doubleValue }
    }
    
    public var timeInterval: TimeInterval {
        get { return self.numberValue.doubleValue }
    }
    
    public var dateValue: Date {
        get {
            let timeInterval = self.numberValue.doubleValue
            return Date(timeIntervalSince1970: timeInterval)
        }
    }
    
    public var dataValue: Data? {
        
        var data: Data?
        if let val = self.value {
            
            switch (type) {
            case SQLITE_INTEGER, SQLITE_FLOAT, SQLITE_TEXT:
                data = String(val).data(using: .utf8)
                break
            case SQLITE_BLOB:
                data = value as? Data
                break
            default:
                break
            }
        }
        
        return data
    }
    
    public var image: UIImage? {
        
        if type == SQLITE_BLOB {
            if let val = value as? Data {
                return UIImage(data: val)
            }
        }
        
        return nil
    }
}
