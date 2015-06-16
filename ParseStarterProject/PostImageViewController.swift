//
//  PostImageViewController.swift
//  ParseStarterProject
//
//  Created by Julian Nicholls on 16/06/2015.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class PostImageViewController: UIViewController {

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var message: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseImagePressed(sender: AnyObject) {
    }

    @IBAction func postImagePressed(sender: AnyObject) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
