//
//  InputViewController.swift
//  taskapp
//
//  Created by NAOTO OMORI on 2016/07/04.
//  Copyright © 2016年 naoto.omori. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    /*
    @IBAction func addCategory(sender: UIButton) {
        let storyboard:UIStoryboard = self.storyboard!
        let categoryViewController = storyboard.instantiateViewControllerWithIdentifier("category") as! AddCategoryViewController
        self.presentViewController(categoryViewController, animated: true, completion: nil)
    }
    */
    var realm = try! Realm()
    var task: Task!
    let category = Category()
    var categoryArray = try! Realm().objects(Category).sorted("id",ascending: true)
    var segueIdentifier = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する。
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(InputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        contentsTextView.layer.borderWidth = 1
        contentsTextView.layer.cornerRadius = 8
        contentsTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        if categoryArray.count == 0 {
            try! realm.write({
                category.id = 0
                category.title = "(カテゴリなし)"
                self.realm.add(category)
            })
        }
        
        for i in 0 ..< categoryArray.count {
            if categoryArray[i].id == task.category!.id {
                categoryPicker.selectRow(i, inComponent: 0, animated: false)
                break
            }
        }
        datePicker.date = task.date
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row].title
    }
    func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.titleTextField.text! != "" && self.segueIdentifier == "" {
            try! realm.write {
                self.task.title = self.titleTextField.text!
                self.task.contents = self.contentsTextView.text
                self.task.category = categoryArray[self.categoryPicker.selectedRowInComponent(0)]
                self.task.date = self.datePicker.date
                self.realm.add(self.task,update: true)
            }
            setNotification(task)
        }
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(animated: Bool) {
        self.segueIdentifier = ""
        categoryArray = try! Realm().objects(Category).sorted("id",ascending: true)
        categoryPicker.reloadAllComponents()
    }

    //タスクのローカル通知を設定する
    func setNotification(task: Task) {
        
        //すでに同じタスクが登録されていたらキャンセルする
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if notification.userInfo!["id"] as! Int == task.id {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break
            }
        }
        
        let notification = UILocalNotification()
        
        notification.fireDate = task.date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "\(task.title)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["id":task.id]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.segueIdentifier = segue.identifier!
    }
}
