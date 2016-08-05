//
//  ZVObject.swift
//  ZVDatabase
//
//  Created by naver on 16/7/28.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public protocol ZVObjectProtocol/*: NSObjectProtocol*/ {
    init()
}

internal extension ZVObjectProtocol {
    
    internal func dictionaryValue(skip:[String] = []) -> [String: Bindable] {
        
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: Bindable]()
        
        for child in mirror.children {
            if let label = child.label {
                if skip.contains(label) { continue }
                let val = _value(for: child.value)
                dictionary[label] = val
            }
        }
        
        return dictionary
    }
    
    private func _value(for anyValue: Any) -> Bindable {
        
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
            let value = anyValue as! NSArray
            if let val = value as? Array<ZVObject> {
                var array = [[String: Bindable]]()
                for item in val {
                    array.append(item.dictionaryValue())
                }
                return array
            } else {
                return value
            }
        case is NSDictionary:
            let value = anyValue as! NSDictionary
            if let val = value as? Dictionary<String, ZVObject> {
                var dictioanry = [String: [String: Bindable]]()
                for (k, v) in val {
                    dictioanry[k] = v.dictionaryValue()
                }
                return dictioanry
            } else {
                return value
            }
        case is Date:
            return anyValue as! Date
        case is ZVObject:
            let value = anyValue as! ZVObject
            return value.dictionaryValue()
        default:
            return NSNull()
        }
    }
}


public class ZVObject: NSObject, ZVObjectProtocol {

    public required override init() {}

}

//MARK: - Collection Bindale
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

