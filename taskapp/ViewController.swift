//
//  ViewController.swift
//  taskapp
//
//  Created by NAOTO OMORI on 2016/07/04.
//  Copyright © 2016年 naoto.omori. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryPicker: UIPickerView!

    var categoryArray = try! Realm().objects(Category).sorted("id",ascending: true)
    
    //Realmインスタンスを取得する    
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト
    //日付近い順でソート
    //移行内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task).sorted("date",ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //categoryText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //再利用可能なcellを得る。
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        //Cellに値を設定する。
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        if task.date.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            cell.detailTextLabel?.textColor = UIColor.redColor()        }
        else{
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    //Deleteボタンが押された時に呼び出されるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            //データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }

    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            inputViewController.task = task
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //categoryText.text = ""
        tableView.reloadData()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text! == "" {
            taskArray = try! Realm().objects(Task).sorted("date",ascending: false)
        } else {
            taskArray = try! Realm().objects(Task).filter("category = '\(textField.text!)'").sorted("date",ascending: false)
        }
        tableView.reloadData()
    }
    //編集直後
    func textFieldDidBeginEditing(textField: UITextField){
        print("textFieldDidBeginEditing:" + textField.text!)
    }
    //編集完了後（完了直前）
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing:" + textField.text!)
        return true
    }
    //改行時
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "" && range.location == 0 && range.length == 1 {
            taskArray = try! Realm().objects(Task).sorted("date",ascending: false)
            tableView.reloadData()
        }
        return true
    }
    
    //UIPickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count + 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "（すべて）"
        } else {
            return categoryArray[row - 1].title
        }
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if 0 == row {
            taskArray = try! Realm().objects(Task).sorted("date",ascending: false)
        }else{
            print("selected: \(row), \(categoryArray[row - 1].title)")
            taskArray = try! Realm().objects(Task).filter("category.id = \(categoryArray[row - 1].id)").sorted("date",ascending: false)
        }
        tableView.reloadData()
    }

}

