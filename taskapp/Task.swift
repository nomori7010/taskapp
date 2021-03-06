//
//  Task.swift
//  taskapp
//
//  Created by NAOTO OMORI on 2016/07/05.
//  Copyright © 2016年 naoto.omori. All rights reserved.
//

import RealmSwift

class Task:Object{
    //管理用ID　プライマリキー
    dynamic var id = 0
    
    //タイトル
    dynamic var title = ""
    
    //内容
    dynamic var contents = ""
    
    //日時
    dynamic var date = NSDate()
    
    //カテゴリ
    dynamic var category:Category? = Category()
    
    /*
    idをプライマリキーとして設定
    */
    override static func primaryKey() -> String? {
        return "id"
    }
}
class Category:Object{
    //管理用ID　プライマリキー
    dynamic var id = 0
    
    //
    dynamic var title = ""
    
    /*
     idをプライマリキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }

}