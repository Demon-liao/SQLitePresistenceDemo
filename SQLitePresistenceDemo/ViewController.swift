//
//  ViewController.swift
//  SQLitePresistenceDemo
//
//  Created by demon on 14-8-1.
//  Copyright (c) 2014年 demon. All rights reserved.
//

import UIKit
//必须加上，别名,使用C中的sqlite3_bind_text函数，不用别名的话，貌似有名字冲突编译不通过
@asmname("sqlite3_bind_text") func sqlite3_bind_string(COpaquePointer, Int32, CString, n: Int32, CFunctionPointer<((UnsafePointer<()>) -> Void)>) -> CInt

class ViewController: UIViewController {
   
    @IBOutlet strong var lineFields: NSArray!
    
    
    var dataFilePath:NSString{
    get{
        var paths:NSArray=NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentsDirectory:NSString=paths.objectAtIndex(0) as NSString
        //            return documentsDirectory.stringByAppendingPathComponent("data.plist") as NSString
        return documentsDirectory.stringByAppendingPathComponent("data.sqlite") as NSString
    }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var database:COpaquePointer = nil
     
        var result=sqlite3_open(self.dataFilePath.UTF8String, &database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            println("open database")
        }
        
        var createSQL:NSString="CREATE TABLE IF NOT EXISTS FIELDS (ROW INTEGER PRIMARY KEY, FIELD_DATA TEXT)"
        var errorMsg:Character
        var statement_exec:COpaquePointer = nil
        //创建表操作 三步
        var _exec = sqlite3_prepare_v2(database, createSQL.UTF8String, -1, &statement_exec, nil)
        sqlite3_step(statement_exec)
        sqlite3_finalize(statement_exec)
        //sqlite3_exec(database, createSQL.UTF8String, callback: nil, 0, nil, 0, nil, errorMsg)
        if(_exec != SQLITE_OK){
            sqlite3_close(database)
            println("(errorMsg)")
        }
        
        var query:NSString="SELECT ROW, FIELD_DATA FROM FIELDS ORDER BY ROW"
        var statement:COpaquePointer = nil
        var _prepare=sqlite3_prepare_v2(database, query.UTF8String, -1, &statement, nil)
        
        if(_prepare == SQLITE_OK){
            println(_prepare)
            while(sqlite3_step(statement) == SQLITE_ROW){
                var row:Int32 = sqlite3_column_int(statement, 0)
                var _txt = UnsafePointer<Int8>(sqlite3_column_text(statement, 1))
                println(row)
                var rowData = CString(_txt)
                var buf:NSString
                if(String.fromCString(rowData) == nil){
                    buf = ""
                }else{
                    buf=String.fromCString(rowData)!
                }
                var fieldValue:NSString = buf //as NSString
                var field:UITextField=self.lineFields[Int(row)] as UITextField
                field.text=fieldValue
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        var app:UIApplication=UIApplication.sharedApplication()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillResiginActive:"), name: UIApplicationWillResignActiveNotification, object: app)

        // Do any additional setup after loading the view, typically from a nib.
    }

    func applicationWillResiginActive(notification:NSNotification){
        var database:COpaquePointer = nil
        var result=sqlite3_open(self.dataFilePath.UTF8String, &database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            println("open database2")
        }
        println(11)
        for(var i = 0; i<4; i++){
            var field:UITextField=self.lineFields[i] as UITextField
            var  update:NSString = "INSERT OR REPLACE INTO FIELDS (ROW, FIELD_DATA) VALUES (?, ?);"
            var errorMsg:UnsafePointer<Int8>=nil
            var stmt:COpaquePointer = nil
            var ret=sqlite3_prepare_v2(database, update.UTF8String, -1, &stmt, nil)
            if( ret == SQLITE_OK){
                //绑定数据，绑定问号里面的值
                sqlite3_bind_int(stmt, 1, Int32(i))
                sqlite3_bind_string(stmt, Int32(2), (field.text as NSString).UTF8String , Int32(-1), nil)
            }
            if(sqlite3_step(stmt) !=  SQLITE_DONE){
                println("22")
            }
            sqlite3_finalize(stmt)
        }
        sqlite3_close(database)
        
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }


}

