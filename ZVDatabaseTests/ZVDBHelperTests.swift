//
//  ZVDBHelperTests.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/16.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import XCTest
@testable import ZVDatabase

class ZVDBHelperTests: XCTestCase {
    
    private var _db: Connection!
    
    override func setUp() {
        super.setUp()
        
        _db = Connection()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        
        self.measure {

        }
    }
    
    func testCreate() {
        let schema = Schema(create: "tb_user", fields: ["userId": "INTEGER PRIMARY KEY AUTOINCREMENT",
                                                        "username": "TEXT NOT NULL",
                                                        "password": "TEXT",
                                                        "remark": "TEXT"])
        do {
            try _db.open()
            try schema.execute(with: _db)
            try _db.close()
        } catch {
            let errMsg = _db.lastErrorMsg
            print(errMsg)
        }
    }
    
    func testInsert() {
        let insert = Insert(["username", "password", "remark"], parameters: ["zevwings", "passwd", "this is a remark"], into: "tb_user")
        
        do {
            try _db.open()
            try insert.execute(with: _db)
            try _db.close()
        } catch {
            let errMsg = _db.lastErrorMsg
            print(errMsg)
        }
    }
    
    func testUpdate() {
        
        let update = Update(["remark"], parameters: ["this is a update remark"], table: "tb_user")
            // Insert(["username", "password", "remark"], parameters: ["zevwings", "passwd", "this is a remark"], into: "tb_user")
        
        do {
            try _db.open()
            try update.execute(with: _db)
            try _db.close()
        } catch {
            let errMsg = _db.lastErrorMsg
            print(errMsg)
        }
    }
    
    func testSelect() {
        
        let select = Select(from: "tb_user")
        
        do {
            try _db.open()
            let rows = try select.query(with: _db)
            print(rows)
            try _db.close()
        } catch {
            let errMsg = _db.lastErrorMsg
            print(errMsg)
        }
    }
    
    func testDelete() {
        
        let delete = Delete(from: "tb_user")
        
        do {
            try _db.open()
            try delete.execute(with: _db)
            try _db.close()
        } catch {
            let errMsg = _db.lastErrorMsg
            print(errMsg)
        }
    }
}
