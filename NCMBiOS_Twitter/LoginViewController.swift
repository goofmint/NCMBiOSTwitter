//
//  LoginViewController.swift
//  NCMBiOS_Twitter
//
//  Created by naokits on 7/8/15.
//  Copyright (c) 2015 Naoki Tsutsui. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 公式のTwitterログイン（使用しません）
    func standardTwitterLogin() {
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in
            // play with Twitter session
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    // ------------------------------------------------------------------------
    // MARK: - Actions
    // ------------------------------------------------------------------------
    
    @IBAction func tappedLoginButton(sender: AnyObject) {
        NCMBTwitterUtils.logInWithBlock { (user: NCMBUser!, error: NSError!) -> Void in
            if let u = user {
                if u.isNew {
                    println("Twitterで登録成功")
                    println("会員登録後の処理")
                    // ACLを本人のみに設定
                    let acl = NCMBACL(user: NCMBUser.currentUser())
                    user.ACL = acl
                    user.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                        if error == nil {
                            println("ACLの保存成功")
                        } else {
                            println("ACL設定の保存失敗: \(error)")
                        }
                        self.performSegueWithIdentifier("unwindFromLogin", sender: self)
                    })
                } else {
                    println("Twitterでログイン成功: \(u)")
                    self.performSegueWithIdentifier("unwindFromLogin", sender: self)
                }
            } else {
                println("Error: \(error)")
                if error == nil {
                    println("Twitterログインがキャンセルされた")
                } else {
                    println("エラー: \(error)")
                }
            }
        }
    }
}
