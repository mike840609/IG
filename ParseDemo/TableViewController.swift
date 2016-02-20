//
//  TableViewController.swift
//  ParseDemo
//
//  Created by 蔡鈞 on 2016/2/20.
//  Copyright © 2016年 abearablecode. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var usernames = [String]()
    var userids = [String]()
    var isFollowing = [String: Bool]()
    
    var refresher : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresher)
        
        refresh()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]
        
        let FollowedObjectId = userids[indexPath.row]
        
        if isFollowing[FollowedObjectId] == true{
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let FollowedObjectId = userids[indexPath.row]
        
        if isFollowing[FollowedObjectId] == false{
            
            isFollowing[FollowedObjectId] = true
            
            cell.accessoryType = .Checkmark
            
            let following = PFObject(className: "followers")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            
            following.saveInBackground()
        }
        else{
            
            isFollowing[FollowedObjectId] = false
            
            cell.accessoryType = .None
            
            let query = PFQuery(className: "followers")
            query.whereKey("follower", equalTo: (PFUser.currentUser()!.objectId)!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects{
                    
                    for object in objects{
                        
                        object.deleteInBackground()
                        
                    }
                }
                
            })
            
        }
        
    }
    
    func refresh(){
        
        let query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects{
                
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity:true)
                
                for object in users{
                    
                    if let user = object as? PFUser{
                        
                        if user.objectId != PFUser.currentUser()?.objectId{
                            
                            // 經由objectId判斷 可以避面將自身加入到陣列當中
                            self.usernames.append(user.username!)
                            self.userids.append(user.objectId!)
                            
                            let query = PFQuery(className: "followers")
                            query.whereKey("follower", equalTo: (PFUser.currentUser()!.objectId)!)
                            query.whereKey("following", equalTo: user.objectId!)
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                
                                if let objects = objects{
                                    
                                    if objects.count > 0{
                                        
                                        self.isFollowing[user.objectId!] = true
                                        
                                    }else{
                                        
                                        self.isFollowing[user.objectId!] = false
                                    }
                                }
                                // 藉由此判斷讓 讓reloadData 只在最後一次執行
                                if self.isFollowing.count == self.usernames.count{
                                    self.tableView.reloadData()
                                    self.refresher.endRefreshing()
                                }
                            })
                        }
                    }
                }
            }
            
        })
        
    }
    
}
