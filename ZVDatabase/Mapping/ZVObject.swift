//
//  ZVObject.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/6.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class ZVObject: NSObject {
    
    public required override init() {}
    
    // you need override this method to figure out the primary key and the property of primary key.
    public func primaryKey() -> (key: String, autoincrement: Bool)? {
        return nil
    }
}

//MARK: - toDictionary
internal extension ZVObject {
    
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
        
        var theValue = anyValue
        
        let mirror = Mirror(reflecting: theValue)
        
        if mirror.displayStyle == .optional {
            if mirror.children.count == 1 {
                theValue = _value(for: mirror.children.first!.value)
            } else if mirror.children.count == 0 {
                return NSNull()
            }
        }
        
        switch theValue {
        case let value as  Int64:
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
            if let val = value as? Array<ZVObject> {
                return val.map({ item in return item.dictionaryValue() })
            } else {
                return value
            }
        case let value as NSDictionary:
            if let val = value as? Dictionary<String, ZVObject> {
                var dictioanry = [String: [String: Bindable]]()
                for (k, v) in val {
                    dictioanry[k] = v.dictionaryValue()
                }
                return dictioanry
            } else {
                return value
            }
        case let value as Date:
            return value
        case let value as ZVObject:
            return value.dictionaryValue()
        default:
            return NSNull()
        }
    }
}

//MARK: - Fields
internal extension ZVObject {
    
    internal func fields() -> [String: String] {
        
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: String]()
        
        for child in mirror.children {
            
            if let label = child.label {
                let val = _type(for: child.value)
                
                if self.primaryKey()?.key == label {
                    var type = val.type() + " " + "PRMARY KEY"
                    let autoincrement = (self.primaryKey()?.autoincrement ?? false) ? " AUTO_INCREMENT " : ""
                    type += autoincrement
                    
                    dictionary[label] = type
                    continue
                }
                
                dictionary[label] = val.type()
            }
        }
        
        return dictionary
    }
    
    private func _type(for anyValue: Any) -> ObjectType {
        
        let type = Mirror(reflecting: anyValue).subjectType
        let typeName = _getClassName(name: String(type))
        
        return ObjectType.value(from: _getClassName(name: typeName))
    }
    
    private func _getClassName(name: String) -> String {
        
        if name.hasPrefix("Dictionary")  {
            return "NSDictionary"
        } else if name.hasPrefix("Array"){
            return "NSArray"
        }
        
        let range = name.range(of: "<.*>", options: .regularExpression)
        
        if range == nil {
            return name
        } else {
            let subName = name.substring(with: range!)
            let subRange = subName.index(subName.startIndex , offsetBy: 1) ..< subName.index(subName.endIndex , offsetBy: -1)
            
            return _getClassName(name: subName.substring(with: subRange))
        }
    }
}
