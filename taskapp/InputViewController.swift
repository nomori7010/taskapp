//
//  InputViewController.swift
//  taskapp
//
//  Created by NAOTO OMORI on 2016/07/04.
//  Copyright © 2016年 naoto.omori. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!
    
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
        categoryTextField.text = task.category
        datePicker.date = task.date
        
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
        if self.titleTextField.text! != "" {
            try! realm.write {
                self.task.title = self.titleTextField.text!
                self.task.contents = self.contentsTextView.text
                self.task.category = self.categoryTextField.text!
                self.task.date = self.datePicker.date
                self.realm.add(self.task,update: true)
            }
            setNotification(task)
        }
        super.viewWillDisappear(animated)
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
}
