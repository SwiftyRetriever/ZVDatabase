//
//  ObjectType.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/11.
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
