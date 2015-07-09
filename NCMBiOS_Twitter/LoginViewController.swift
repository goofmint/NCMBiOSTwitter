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
        
        
        NCMBTwitterUtils.logInWithBlock { (user: NCMBUser!, error: NSError!) -> Void in
            if let u = user {
                if u.isNew {
                    println("Twitterで登録成功")
                } else {
                    println("Twitterでログイン成功: \(u)")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func twitterLogin() {
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in
            // play with Twitter session
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }

}
