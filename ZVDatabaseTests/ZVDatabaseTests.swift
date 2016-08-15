//
//  ZVDatabaseTests.swift
//  ZVDatabaseTests
//
//  Created by naver on 16/7/28.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import XCTest
@testable import ZVDatabase

class ZVDatabaseTests: XCTestCase {
    
    var db: Connection?
    
    override func setUp() {
        super.setUp()
        
        db = Connection()
        
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
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCreateTable() {
        
        let connection = Connection()
        var result:Bool = false
        do {
            try connection.open()
            try connection.executeUpdate("CREATE TABLE Persons(Id_P int, LastName varchar(255), FirstName varchar(255), Address varchar(255), City varchar(255))")
            try connection.close()
            
            result = true
            
        } catch {
            
        }
        
        XCTAssertTrue(result)
        
    }
    
    func testInsertValue() {
        
        let connection = Connection()
        var rowId: Int64? = 0
        do {
            try connection.open()
            let sql = "INSERT INTO Persons (Id_P, LastName, FirstName, Address, City) VALUES (?, ?, ?, ?, ?)"
            rowId = try connection.exceuteUpdate(sql,
                                                 parameters: [9527, "Wings", "Zev", "Gulou Street", "Chengdu"],
                                                 lastInsertRowid: true)
            
            
            try connection.close()
            
        } catch {
            
        }
        
        XCTAssertTrue(rowId > 0)
    }
    
    func testUpdateValue() {
        
        let connection = Connection()
        var changes: Int64? = 0
        do {
            try connection.open()
            let sql = "UPDATE Persons SET LastName = ? WHERE Id_P = ?"
            changes = try connection.exceuteUpdate(sql,
                                                   parameters: ["Zhang", 9527],
                                                   lastInsertRowid: false)
            
            try connection.close()
            
        } catch {
            
        }
        
        XCTAssertTrue(changes > 0)
    }
    
    func testDeleteValue() {
        
        let connection = Connection()
        var changes: Int64? = 0
        do {
            try connection.open()
            let sql = "DELETE FROM Persons"
            changes = try connection.exceuteUpdate(sql)
            
            try connection.close()
            
        } catch {
            
        }
        
        XCTAssertTrue(changes > 0)
    }
    
    // if this test failed, the queue is start.
    func testQueue() {
        //        let path = NSHomeDirectory() + "/db.sqlite"
        let queue = DispatchQueue(label: "com.zevwinsg.dbqueue")
        let dbQueue = DatabaseQueue(path: "", queue: queue)
        
        var changes: Int64? = 0
        dbQueue.inBlock { (db) in
            
            do {
                try db.open()
                for index in 0 ..< 100 {
                    let sql = "INSERT INTO Persons (Id_P, LastName, FirstName, Address, City) VALUES (?, ?, ?, ?, ?)"
                    changes = try db.exceuteUpdate(sql,
                                                   parameters: [index, "Wings", "Zev", "Gulou Street", "Chengdu"],
                                                   lastInsertRowid: false)
                }
                try db.close()
            } catch {
                let e = error
                print(e)
            }
        }
        
        XCTAssert(changes >= 100)
        
    }
    
    func testTransaction() {
        
        let queue = DispatchQueue(label: "com.zevwinsg.dbqueue")
        let dbQueue = DatabaseQueue(queue: queue)
        
        dbQueue.inTransaction { (db) -> Bool in
            var changes: Int64? = 0
            var success = true
            do {
                for index in 100 ..< 200 {
                    let sql = "INSERT INTO Persons (Id_P, LastName, FirstName, Address, City) VALUES (?, ?, ?, ?, ?)"
                    changes = try db.exceuteUpdate(sql,
                                                   parameters: [index, "Wings", "Zev", "Gulou Street", "Chengdu"],
                                                   lastInsertRowid: false)
                }
                
            } catch {
                success = false
            }
            changes = Int64(db.totalChanges)
            XCTAssert(changes >= 100)
            return success
        }
    }
    
    func testPoolInBlock() {
        let pool = DatabasePool()
        do {
            XCTAssert(pool.activeDatabaseCount == 0)
            XCTAssert(pool.inactiveDatabaseCount == 0)
            try pool.inBlock { (db) in
                
                XCTAssert(pool.activeDatabaseCount == 1)
                XCTAssert(pool.inactiveDatabaseCount == 0)
                do {
                    try db.executeUpdate("CREATE TABLE Persons(Id_P int, LastName varchar(255), FirstName varchar(255), Address varchar(255), City varchar(255))");
                } catch {
                    
                }
            }
            
            XCTAssert(pool.activeDatabaseCount == 0)
            XCTAssert(pool.inactiveDatabaseCount == 1)
            
        } catch {
            print(error)
        }
    }
    
    func testPoolInTransaction() {
        
        let pool = DatabasePool()
        do {
            
            try pool.inTransaction({ (db) -> Bool in
                
                XCTAssert(pool.activeDatabaseCount == 1)
                XCTAssert(pool.inactiveDatabaseCount == 0)
                do {
                    try db.executeUpdate("CREATE TABLE Persons(Id_P int, LastName varchar(255), FirstName varchar(255), Address varchar(255), City varchar(255))");
                } catch {
                    
                }
                
                
                return false
            })
            
            XCTAssert(pool.activeDatabaseCount == 0)
            XCTAssert(pool.inactiveDatabaseCount == 1)
            
        } catch {
            print(error)
        }
    }

    func testSchema() {
        let cmd = Schema(create: "tb_user", fields: [:])
    }
}

