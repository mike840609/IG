//
//  SignUpViewController.swift
//  ParseDemo
//
//  Created by Rumiya Murtazina on 7/30/15.
//  Copyright (c) 2015 abearablecode. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //點擊輸入框以外地方隱藏鍵盤
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //點擊 Sign Up 觸發 通過驗證 呼叫 parse signUpInBackgroundWithBlock 函式 並採非同步方式
    @IBAction func signUpAction(sender:AnyObject){
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        let finalEmail = email?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //驗證文字欄位
        if let username = username where username.characters.count < 5 {
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        }else if let password = password where password.characters.count < 8 {
            let alert = UIAlertView(title: "Invalid", message: "Password must be greater than 8 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }else if let email = email where email.characters.count < 8 {
            let alert = UIAlertView(title: "Invalid", message: "Please enter a valid email address", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }else{
            
            //旋轉動畫 代表工作運行
            let spinner:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            newUser.username = username
            newUser.password = password
            newUser.email = email
            
            //以非同步方式註冊使用者
            newUser.signUpInBackgroundWithBlock({(succed,error) -> Void in
                
                //停止旋轉
                spinner.stopAnimating()
                
                if((error) != nil){
                    if(error?.code == 202){
                        let alert = UIAlertView(title: "failed", message: "用戶名已經註冊", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    else if (error?.code == 200){
                        let alert = UIAlertView(title: "failed", message: "帳號為空", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                        
                    }
                    else if (error?.code == 201){
                        let alert = UIAlertView(title: "failed", message: "密碼為空", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                        
                    }
                        
                    else{
                        let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }else{
                    let alert = UIAlertView(title: "Success", message: "Signned Up", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
                        self.presentViewController(viewController, animated: true, completion: nil)
                        
                    })
                    
                }
                
            })
            
            
        }
    }
    
    
    //隱藏鍵盤
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
