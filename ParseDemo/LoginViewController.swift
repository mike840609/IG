//
//  LoginViewController.swift
//  ParseDemo
//
//  Created by Rumiya Murtazina on 7/28/15.
//  Copyright (c) 2015 abearablecode. All rights reserved.

//自動登入 viewdidload 方法  刪除 並將 75 行註解拿掉 

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil{
            
            // 登入成功使用 login Segue 轉跳 拿掉後就不會存取要每次重新登入
            //self.performSegueWithIdentifier("login", sender: self)
            
        
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(sender:AnyObject){
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        //驗證文字
        if let username = username where username.characters.count < 5 {
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        }else if let password = password where password.characters.count < 8 {
            let alert = UIAlertView(title: "Invalid", message: "Password must be greater than 8 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }else{
            
            //旋轉動畫 表示登入中
            let spinner:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            //送出登入要求 parse 內建方法
            PFUser.logInWithUsernameInBackground(username!, password:password!, block: {(user,error) -> Void in
                
                spinner.stopAnimating()
                
                if(user != nil){
                    
                    let alert = UIAlertView(title: "Success", message: "Login In", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                    /*
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
                        
                        self.presentViewController(viewController, animated: true, completion: nil)
                        
                    })
                    */
                    
                    
                    // 登入成功使用 login Segue 轉跳 若要每次登入則把下方拿掉註解取代 並把viewdidappear方法刪除 
                    self.performSegueWithIdentifier("login", sender: self)
                    
                }else{
                    
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                }
            })
        }
    }
    
    
    // 隱藏鍵盤
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
    }
    
    
    
    
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue){
        
    }
    
    
    
    
}
