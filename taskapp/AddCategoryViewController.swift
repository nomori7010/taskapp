//
//  AddCategoryViewController.swift
//  taskapp
//
//  Created by NAOTO OMORI on 2016/07/11.
//  Copyright © 2016年 naoto.omori. All rights reserved.
//

import UIKit
import RealmSwift

class AddCategoryViewController: UIViewController {
    
    let realm = try! Realm()
    var category = Category()
    
    @IBOutlet weak var categoryTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        let titleText = self.categoryTitle.text!
        if titleText != "" {
            let categoryArray = try! Realm().objects(Category)
            try! realm.write {
                self.category.title = self.categoryTitle.text!
                if categoryArray.count != 0 {
                    self.category.id = categoryArray.max("id")! + 1
                }
                self.realm.add(self.category,update: true)
            }
        }
        
        super.viewWillDisappear(true)
    }
}
