//
//  DetailViewController.swift
//  NCMBiOS_Twitter
//
//  Created by naokits on 7/4/15.
//  Copyright (c) 2015 Naoki Tsutsui. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    /// TODOのタイトル
    @IBOutlet weak var todoTitle: UITextField!
    
    /// 追加/更新共用ボタン
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    var detailItem: Todo? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let title = self.todoTitle {
                title.text = detail.title
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
