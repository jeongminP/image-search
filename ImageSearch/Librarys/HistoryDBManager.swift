//
//  HistoryDBManager.swift
//  ImageSearch
//
//  Created by USER on 2020/07/13.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation
import SQLite3

final class HistoryDBManager {
    static let shared = HistoryDBManager()
    
    private var db: OpaquePointer?
    
    private var dbPath: String = ""
    private let dbName: String = "history.db"
    
    private let sqlCreate: String = "CREATE TABLE IF NOT EXISTS HISTORY ( "
        + " ID    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "
        + " KEYWORD  CHAR(255) NOT NULL, "
        + " DATE CHAR(255) "
        + ");"
    
    private let sqlInsert: String = "INSERT INTO HISTORY (KEYWORD, DATE) VALUES (? , ?);"
    private let sqlSelect: String = "SELECT ID, KEYWORD, DATE FROM HISTORY ORDER BY DATE DESC;"
    private let sqlUpdate: String = "UPDATE HISTORY SET KEYWORD=?, DATE=? WHERE ID=?;"
    private let sqlDelete: String = "DELETE FROM HISTORY WHERE ID=?;"
    
    init() {
        createTable()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    private func createTable() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docPath = dirPath[0]
        
        dbPath = docPath+"/"+dbName

        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(dbPath)")
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
        }
        
        if let db = db {
            var createTableStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, sqlCreate, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
                    print("History table created.")
                } else {
                    print("History table could not be created.")
                }
            } else {
                let errorMessage = String.init(cString: sqlite3_errmsg(db))
                print("CREATE TABLE statement could not be prepared. \(errorMessage)")
            }
            sqlite3_finalize(createTableStatement)
        }
    }
    
    func insert(keyword: String, date: String) {
        var insertStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, sqlInsert, -1, &insertStmt, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStmt, 1, (keyword as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStmt, 2, (date as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStmt) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("INSERT statement could not be prepared. \(errorMessage)")
        }
        sqlite3_finalize(insertStmt)
    }
    
    func read() -> [SearchHistoryModel] {
        var queryStmt: OpaquePointer? = nil
        var historyArray: [SearchHistoryModel] = []
        
        if sqlite3_prepare_v2(db, sqlSelect, -1, &queryStmt, nil) == SQLITE_OK {
            while sqlite3_step(queryStmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStmt, 0))
                let queryResultCol1 = sqlite3_column_text(queryStmt, 1)
                let queryResultCol2 = sqlite3_column_text(queryStmt, 2)
                
                guard let col1 = queryResultCol1,
                    let col2 = queryResultCol2 else {
                        return historyArray
                }
                let keyword = String(cString: col1)
                let date = String(cString: col2)
                
                historyArray.append(SearchHistoryModel(id: id, keyword: keyword, date: date))
            }
        } else {
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("SELECT statement could not be prepared! \(errorMessage)")
        }
        sqlite3_finalize(queryStmt)
        
        return historyArray
    }
    
    func update(history: SearchHistoryModel) {
        var updateStmt: OpaquePointer? = nil
        
        guard let id = history.id,
            let keyword = history.keyword,
            let date = history.date else {
                return
        }
        
        if sqlite3_prepare_v2(db, sqlUpdate, -1, &updateStmt, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStmt, 1, (keyword as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStmt, 2, (date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStmt, 3, Int32(id))
            
            if sqlite3_step(updateStmt) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("UPDATE statement could not be prepared! \(errorMessage)")
        }
        sqlite3_finalize(updateStmt)
    }
    
    func delete(history: SearchHistoryModel) {
        var deleteStmt: OpaquePointer? = nil
        guard let id = history.id else {
            return
        }
        
        if sqlite3_prepare_v2(db, sqlDelete, -1, &deleteStmt, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStmt, 1, Int32(id))
            
            if sqlite3_step(deleteStmt) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("DELETE statement could not be prepared! \(errorMessage)")
        }
        
        sqlite3_finalize(deleteStmt)
    }
}
