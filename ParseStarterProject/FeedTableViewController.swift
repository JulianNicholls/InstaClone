//
//  FeedTableViewController.swift
//  ParseStarterProject
//
//  Created by Julian Nicholls on 16/06/2015.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {

    var users       = [String: String]()
    var userNames   = [""]
    var imageFiles  = [PFFile()]
    var captions    = [""]

    override func viewDidLoad() {
        super.viewDidLoad()

        userNames.removeAll(keepCapacity: true)
        users.removeAll(keepCapacity: true)
        captions.removeAll(keepCapacity: true)
        imageFiles.removeAll(keepCapacity: true)

        var userQuery = PFUser.query()

        userQuery?.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in

            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        self.users[user.objectId!] = user.username!
                    }
                }
            }

            var followQuery = PFQuery(className: "Relation")

            followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)

            followQuery.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in

                if let objects = objects {
                    for object in objects {
                        let followedUser = object["following"] as! String

                        var imageQuery = PFQuery(className: "Post")

                        imageQuery.whereKey("userId", equalTo: followedUser)

                        imageQuery.findObjectsInBackgroundWithBlock({
                            (objects, error) -> Void in

                            if let objects = objects {
                                for object in objects {
                                    self.imageFiles.append(object["imageFile"] as! PFFile)
                                    self.captions.append(object["caption"] as! String)
                                    self.userNames.append(self.users[object["userId"] as! String]!)

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
        return userNames.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! Cell

        imageFiles[indexPath.row].getDataInBackgroundWithBlock {
            (data, error) -> Void in

            if let image = UIImage(data: data!) {
                cell.postedImage.image = image
            }
        }

        cell.userName.text  = userNames[indexPath.row]
        cell.caption.text   = captions[indexPath.row]

        return cell
    }
}