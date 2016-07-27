//
//  ZVDatabaseTests.swift
//  ZVDatabaseTests
//
//  Created by ZERO on 16/7/2.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import XCTest
@testable import ZVDatabase

class ZVDatabaseTests: XCTestCase {
    
    var connection: Connection?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
    
    func testQuery() {
        
        let connection = Connection()
//        var rows: [[String: Binding]]
        do {
            try connection.open()
//            let i: Binding = 0
            let sql = "SELECT Id_P, LastName, FirstName, Address, City FROM Persons WHERE Id_P = ?"
            let rows = try connection.executeQuery(sql, parameters: [10])
            let row  = rows[0]
            let col = row["Id_P"]

            XCTAssertTrue(c == "10")
//            numberValue
//            if col == nil {
//                
//            } else if col?.stringValue == "Wings" {
//                
//            }
//            let row = rows?[0]
//            let col = row?["LastName"]
//            let i: Int = col
//            print(i)
            try connection.close()
            
        } catch {
            
        }
        
//        let lastName = rows?[0]["LastName"]
        
//            ?.stringValue
//        XCTAssertTrue(lastName == "Wings")
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
