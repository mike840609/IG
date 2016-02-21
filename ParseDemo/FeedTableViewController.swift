//
//  FeedTableViewController.swift
//  ParseDemo
//
//  Created by 蔡鈞 on 2016/2/21.
//  Copyright © 2016年 abearablecode. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {
    
    var messages = [String]()
    var usernames = [String]()
    var imageFiles = [PFFile]()
    var users = [String: String]()
    
    var test = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                self.messages.removeAll(keepCapacity: true)
                self.users.removeAll(keepCapacity: true)
                self.imageFiles.removeAll(keepCapacity: true)
                self.usernames.removeAll(keepCapacity: true)
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        self.users[user.objectId!] = user.username!

                    }
                }
            }
            
            
            //debug 測試字典中是否正確寫入 (成功寫入字典)
            //for i in self.users{
            //print(i.0 + "-" + i.1)
            //}
            //======================================
            
            let getFollowedUsersQuery = PFQuery(className: "followers")
            
            getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            
            print("當前登入id " + PFUser.currentUser()!.objectId!)
            
            getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
               
                print (objects!.count)
            
                // 這裡回傳的 objects 陣列 為 follower 欄位為 當前為 PFUser.currentUser()!.objectId! 的object組成
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        // 這裡獲得所有 符合follower欄位是PFUser.currentUser()!.objectId! 的 following 欄位
                        let followedUser = object["following"] as! String
                        
                        //print(followedUser)
                        
                        let query = PFQuery(className: "Post")
                        
                        query.whereKey("userId", equalTo: followedUser)
                        
                        print(followedUser)
                        

                        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            
                            if let objects = objects {
                                
                                for object in objects {
                                    
                                    print("追蹤中id \(object["userId"] as! String)")
                                    
                                    self.messages.append(object["message"] as! String)
                                    
                                    self.imageFiles.append(object["imageFile"] as! PFFile)
                                    
                                    self.usernames.append(self.users[object["userId"] as! String]!)
                                    
                                    self.tableView.reloadData()
                                    
                                }
                                
                            }
                            
                        })
                    }
                    
                }
                
            }
            
        })
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return usernames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let myCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedCellTableViewCell
        
        imageFiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
            
            if let downloadedImage = UIImage(data: data!) {
                
                myCell.postedImage.image = downloadedImage
                
            }
            
        }
        
        myCell.username.text = usernames[indexPath.row]
        
        myCell.message.text = messages[indexPath.row]
        
        return myCell
    }
    
    
    @IBAction func logOut(sender: AnyObject){
        
        //傳送使用者要求
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    
}
