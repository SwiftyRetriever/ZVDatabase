//
//  Binding+Collection.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/6.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

//MARK: - Collection Bindale

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

extension NSArray: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        try statement.bind(dataValue: data, at: index)
    }
}

extension Array: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        
        let array = self.map { (element) -> AnyObject in
            return self.value(for: element)
        }
        
        let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
        if data.count == 0 {
            try statement.bind(nullValueAt: index)
        } else {
            try statement.bind(dataValue: data, at: index)
        }
    }
}

extension NSDictionary: Bindable {
    
    public func bind(to statement: Statement, at index: Int) throws {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        try statement.bind(dataValue: data, at: index)
    }
}

extension Dictionary: Bindable  {
    
    public func bind(to statement: Statement, at index: Int) throws {
        
        var dictionary = [String: AnyObject]()
        
        for (key, value) in self {
            
            if let _key = key as? String {
                dictionary.updateValue(self.value(for: value), forKey: _key)
            } else {
                continue
            }
        }
        
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        if data.count == 0 {
            try statement.bind(dataValue: data, at: index)
        } else {
            try statement.bind(dataValue: data, at: index)
        }
    }
}
