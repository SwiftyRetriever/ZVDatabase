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
        case let value as Int64:
            return NSDecimalNumber(value: value)
        case let value as Int32:
            return NSDecimalNumber(value: value)
        case let value as Int16:
            return NSDecimalNumber(value: value)
        case let value as Int8:
            return NSDecimalNumber(value: value)
        case let value as UInt64:
            return NSDecimalNumber(value: value)
        case let value as UInt32:
            return NSDecimalNumber(value: value)
        case let value as UInt16:
            return NSDecimalNumber(value: value)
        case let value as UInt8:
            return NSDecimalNumber(value: value)
        case let value as Double:
            return NSDecimalNumber(value: value)
        case let value as Float:
            return NSDecimalNumber(value: value)
        case let value as NSNumber:
            return value
        case let value as String:
            return value
        case let value as NSArray:
            return value
        case let value as NSDictionary:
            return value
        case let value as Date:
            return value
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
