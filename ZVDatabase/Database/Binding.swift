//
//  ZVBindable.swift
//  ZVDatabase
//
//  Created by naver on 16/7/27.
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


public protocol Bindable {
    
    func bind(to statement: Statement, at index: Int) throws
    
}

public protocol Number: Bindable {}

internal extension Collection {
    
    internal func value(for anyValue: Any) -> AnyObject {
        
        switch anyValue {
        case is Int64:
            return NSDecimalNumber(value: anyValue as! Int64)
        case is Int32:
            return NSDecimalNumber(value: anyValue as! Int32)
        case is Int16:
            return NSDecimalNumber(value: anyValue as! Int16)
        case is Int8:
            return NSDecimalNumber(value: anyValue as! Int8)
        case is UInt64:
            return NSDecimalNumber(value: anyValue as! UInt64)
        case is UInt32:
            return NSDecimalNumber(value: anyValue as! UInt32)
        case is UInt16:
            return NSDecimalNumber(value: anyValue as! UInt16)
        case is UInt8:
            return NSDecimalNumber(value: anyValue as! UInt8)
        case is Double:
            return NSDecimalNumber(value: anyValue as! Double)
        case is Float:
            return NSDecimalNumber(value: anyValue as! Float)
        case is NSNumber, is Int, is UInt:
            return anyValue as! NSNumber
        case is String, is NSString:
            return anyValue as! String
        case is NSArray:
            return anyValue as! NSArray
        case is NSDictionary:
            return anyValue as! NSDictionary
        case is Date:
            return anyValue as! Date
        default:
            return NSNull()
        }
    }
}

// MARK: - Number
extension Int8: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(intValue: Int(self), at: index)
    }
}

extension UInt8: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(intValue: Int(self), at: index)
    }
}

extension Int16: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(intValue: Int(self), at: index)
    }
}

extension UInt16: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(intValue: Int(self), at: index)
    }
}

extension Int32: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(intValue: Int(self), at: index)
    }
}

extension UInt32: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(int64Value: Int64(self), at: index)
    }
}

extension Int64: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(int64Value: Int64(self), at: index)
    }
}

extension UInt64: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(int64Value: Int64(self), at: index)
    }
}

extension Int: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(int64Value: Int64(self), at: index)
    }
}

extension UInt: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(int64Value: Int64(self), at: index)
    }
}

extension Double: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(doubleValue: self, at: index)
    }
}

extension Float: Number {
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(doubleValue: Double(self), at: index)
    }
}

extension Bool: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(intValue: Int(self), at: index)
    }
}

extension NSNumber: Number {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(int64Value: self.int64Value, at: index)
    }
}

//MARK: - Null
extension NSNull: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(nullValueAt: index)
    }
}

//MARK: - String
extension String: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(textValue: self, at: index)
    }
}

extension NSString: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(textValue: self as String, at: index)
    }
}

//MARK: - NSDate
extension NSDate: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(doubleValue: self.timeIntervalSince1970, at: index)
    }
}

extension Date: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(doubleValue: self.timeIntervalSince1970, at: index)
    }
}

//MARK: - NSData
extension NSData: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(dataValue: self, at: index)
    }
}

extension Data: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(dataValue: self, at: index)
    }
}
