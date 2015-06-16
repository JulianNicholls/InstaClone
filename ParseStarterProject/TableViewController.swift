//
//  TableViewController.swift
//  ParseStarterProject
//
//  Created by Julian Nicholls on 12/06/2015.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {

    var userNames   = [""]
    var userIDs     = [""]
    var followed    = ["":false]

    var refresher : UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for 
        // this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        // Set up pull to refresh

        refresher = UIRefreshControl()

        refresher.attributedTitle = NSAttributedString(string: "Refresh Users")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)

        self.tableView.addSubview(refresher)

        refresh()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let id   = userIDs[indexPath.row]

        // Configure the cell...

        cell.textLabel?.text = userNames[indexPath.row]

        if followed[id]! {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)!
        let id   = userIDs[indexPath.row]

        if !followed[id]! {
            followed[id] = true

            // Find this cell and add a check mark to show following status

            cell.accessoryType = UITableViewCellAccessoryType.Checkmark

            // Create the relationship

            var relation = PFObject(className: "Relation")

            relation["following"] = id
            relation["follower"]  = PFUser.currentUser()?.objectId
            relation.saveInBackground()
        }
        else {
            followed[id] = false
            cell.accessoryType = UITableViewCellAccessoryType.None

            var relQuery = PFQuery(className: "Relation")

            relQuery.whereKey("following", equalTo: id)
            relQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)

            relQuery.findObjectsInBackgroundWithBlock({
                (objects, error) -> Void in

                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
        }
    }

    ////////////
    // Pull to refresh code

    func refresh() {
        fillUsersTable()
    }

    ///////////////
    // Fill the users and followers tables
    
    func fillUsersTable() {
        var userQuery = PFUser.query()

        userQuery?.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in

            if let users = objects {
                self.userNames.removeAll(keepCapacity: true)
                self.userIDs.removeAll(keepCapacity: true)
                self.followed.removeAll(keepCapacity: true)

                for object in users {
                    if let user = object as? PFUser {
                        if PFUser.currentUser()?.objectId != user.objectId {
                            self.userNames.append(user.username!)
                            self.userIDs.append(user.objectId!)

                            self.setupFollowed(user.objectId!)
                        }
                    }
                }
            }
        })
    }

    func setupFollowed(id: String) {
        var relQuery = PFQuery(className: "Relation")

        relQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
        relQuery.whereKey("following", equalTo: id)

        relQuery.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in

            if let objects = objects {
                if objects.count > 0 {
                    // Any reply must imply a relation
                    self.followed[id] = true
                }
                else {  // Good reply, but no users
                    self.followed[id] = false
                }
            }
            else {  // Bad reply
                self.followed[id] = false
            }

            // This reload has been moved here because of the asynchronicity of
            // filling in the various arrays

            if self.followed.count == self.userNames.count {
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        })
    }
}
