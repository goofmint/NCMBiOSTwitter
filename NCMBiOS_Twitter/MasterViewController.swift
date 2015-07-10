//
//  MasterViewController.swift
//  NCMBiOS_Twitter
//
//  Created by naokits on 7/4/15.
//  Copyright (c) 2015 Naoki Tsutsui. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    /// TODOを格納する配列
    var objects = [Todo]()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let user = NCMBUser.currentUser() {
            self.fetchAllTodos()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = NCMBUser.currentUser() {
            println("ログイン中: \(user)")
        } else {
            println("ログインしていない")
            self.performSegueWithIdentifier("toLogin", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ------------------------------------------------------------------------
    // MARK: - Segues
    // ------------------------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goEditTodo" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = self.objects[indexPath.row]
                if let dvc = segue.destinationViewController as? DetailViewController {
                    dvc.detailItem = object
                    dvc.updateButton.title = "更新"
                }
            }
        } else if segue.identifier == "goAddTodo" {
            (segue.destinationViewController as! DetailViewController).updateButton.title = "追加"
        } else if segue.identifier == "toLogin" {
            println("ログアウトしてログイン画面に遷移します")
            NCMBUser.logOut()
        } else {
            // 遷移先が定義されていない
        }
    }
    
    /// TODO登録／編集画面から戻ってきた時の処理を行います。
    @IBAction func unwindFromTodoEdit(segue:UIStoryboardSegue) {
        println("---- unwindFromTodoEdit: \(segue.identifier)")
        let svc = segue.sourceViewController as! DetailViewController
        if count(svc.todoTitle.text) < 3 {
            return
        }
        
        if svc.detailItem == nil {
            println("TODOオブジェクトが存在しないので、新規とみなします。")
            println("\(svc.todoTitle.text)")
            self.addTodoWithTitle(svc.todoTitle.text)
        } else {
            println("更新処理")
            svc.detailItem?.title = svc.todoTitle.text
            svc.detailItem?.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    /// ログイン画面から戻ってきた時の処理を行います。
    @IBAction func unwindFromLogin(segue:UIStoryboardSegue) {
        // ログインが終了したら強制的にTODO一覧を取得
        self.objects = [Todo]()
        self.fetchAllTodos()
    }

    // ------------------------------------------------------------------------
    // MARK: - Table View
    // ------------------------------------------------------------------------

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let todo = objects[indexPath.row]
        cell.textLabel!.text = todo.objectForKey("title") as? String
        cell.textLabel!.text = todo.title

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // ------------------------------------------------------------------------
    // MARK: Methods for Data Source
    // ------------------------------------------------------------------------
    
    /// 全てのTODO情報を取得し、プロパティに格納します
    ///
    /// :param: None
    /// :returns: None
    func fetchAllTodos() {
        // クエリを生成
        let query = Todo.query() as NCMBQuery
        // タイトルにデータが含まれないものは除外
        query.whereKeyExists("title")
        // 登録日の降順で取得
        query.orderByDescending("createDate")
        // 取得件数の指定
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock({(NSArray todos, NSError error) in
            if (error == nil) {
                println("登録件数: \(todos.count)")
                for todo in todos {
                    println("--- \(todo.objectId): \(todo.title)")
                }
                self.objects = todos as! [Todo] // NSArray -> Swift Array
                self.tableView.reloadData()
            } else {
                println("Error: \(error)")
            }
        })
    }
    
    /// 新規にTODOを追加します
    ///
    /// :param: title TODOのタイトル
    /// :returns: None
    func addTodoWithTitle(title: String) {
        let todo = Todo.object() as! Todo
        todo.title = title
        todo.ACL = NCMBACL(user: NCMBUser.currentUser())
        
        // 非同期で保存
        todo.saveInBackgroundWithBlock { (error: NSError!) -> Void in
            if error == nil {
                println("新規TODOの保存成功。表示の更新などを行う。")
                self.insertNewTodoObject(todo)
            } else {
                println("新規TODOの保存に失敗しました: \(error)")
            }
        }
    }
    
    /// TODOをDataSourceに追加して、表示を更新します
    ///
    /// :param: todo TODOオブジェクト（NCMBObject）
    /// :returns: None
    func insertNewTodoObject(todo: Todo!) {
        self.objects.insert(todo, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.tableView.reloadData()
    }
}
