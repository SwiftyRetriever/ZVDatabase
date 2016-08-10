//
//  ZVObject.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/6.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public enum ObjectType {
    
    case Int64
    case Int32
    case Int16
    case Int8
    case Int
    case UInt64
    case UInt32
    case UInt16
    case UInt8
    case UInt
    case Double
    case Float
    case NSNumber
    case Bool
    case String
    case NSArray
    case NSDictionary
    case Date
    case Object
    case Null
    case UnKnown
    
    func type() -> String {
        switch self {
        case .Int64, .Int32, .Int16, .Int8, .Int,
             .UInt64, .UInt32, .UInt16, .UInt8, .UInt, .Bool:
            return "INTEGER"
        case .Double, .Float, .NSNumber, .Date:
            return "DOUBLE"
        case .String:
            return "TEXT"
        case .NSArray, .NSDictionary, .Object:
            return "BLOB"
        default:
            return ""
        }
    }
    
    static func value(from string: String) -> ObjectType {
        switch string {
        case "Int64":
            return Int64
        case "Int32":
            return Int32
        case "Int16":
            return Int16
        case "Int8":
            return Int8
        case "UInt64":
            return UInt64
        case "UInt32":
            return UInt32
        case "UInt16":
            return UInt16
        case "UInt8":
            return UInt8
        case "Bool":
            return Bool
        case "Double":
            return Double
        case "Float":
            return Float
        case "NSNumber":
            return NSNumber
        case "Int":
            return Int
        case "UInt":
            return UInt
        case "String":
            return String
        case "NSArray":
            return NSArray
        case "NSDictionary":
            return NSDictionary
        case "Date":
            return Date
        case "Object":
            return Object
        case "Null":
            return Null
        default:
            return UnKnown
        }
    }
}

public class ZVObject: NSObject {
    
    public required override init() {}
    
    // you need override this method to figure out the primary key and the property of primary key.
    public func primaryKey() -> (key: String, autoincrement: Bool)? {
        return nil
    }
}

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
                return val.map({ item in return item.dictionaryValue() })
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
