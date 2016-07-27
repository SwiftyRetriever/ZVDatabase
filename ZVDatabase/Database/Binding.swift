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


public protocol Binding {
    
    func bind(to statement: Statement, at index: Int) throws
    
}

protocol Number: Binding {}

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
extension NSNull: Binding {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(nullValueAt: index)
    }
}

//MARK: - String
extension String: Binding {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(textValue: self, at: index)
    }
}

extension NSString: Binding {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(textValue: self as String, at: index)
    }
}

//MARK: - NSDate
extension NSDate: Binding {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(doubleValue: self.timeIntervalSince1970, at: index)
    }
}

extension Date: Binding {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(doubleValue: self.timeIntervalSince1970, at: index)
    }
}

//MARK: - NSData
extension NSData: Binding {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(dataValue: self, at: index)
    }
}

extension Data: Binding {
    
    public func bind(to statement: Statement, at index: Int) throws {
        try statement.bind(dataValue: self, at: index)
    }
}
