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
    var users = [String:String]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print(PFUser.currentUser()!.objectId!)
        
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

            
            let getFollowedUserQuery = PFQuery(className: "followers")
            
            getFollowedUserQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            
            getFollowedUserQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                if let objects = objects{
                    
                    for object in objects{
                        
                        let followedUser = object["following"] as! String
                        
                        let query = PFQuery(className: "Post")
                        
                        query.whereKey("userId", equalTo: followedUser)
                        
                        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            
                            if let objects = objects{
                                
                                for object in objects {
                                    
                                    self.messages.append(object["message"] as! String)
                                    self.imageFiles.append(object["imageFile"] as! PFFile)
                                    self.usernames.append(self.users[object["userId"] as! String]!)
                                    self.tableView.reloadData()
                                   
                                    //print(self.messages)
                                    
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
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let myCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedCellTableViewCell
        
        myCell.postedImage.image = UIImage(named: "user")
        
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
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
