//
//  ZVDatabasePool.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit

// TODO: - 完成连接池
public class ZVDatabasePool: NSObject {
    
    private struct Singleton {
        static var pool: ZVDatabasePool?
    }
    
    public static let shared: ZVDatabasePool = ZVDatabasePool()
    
//    override class func initialize() {
//        super.initialize()
//    }
    
}
