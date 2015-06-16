//
//  PostImageViewController.swift
//  ParseStarterProject
//
//  Created by Julian Nicholls on 16/06/2015.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var indicator = UIActivityIndicatorView()

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var caption: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseImagePressed(sender: AnyObject) {
        var image = UIImagePickerController()

        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        self.presentViewController(image, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)

        imageToPost.image = image
    }

    @IBAction func postImagePressed(sender: AnyObject) {
        println(imageToPost.image?.description)

        if imageToPost.image == nil {
            displayAlert("No image is selected", message: "You must select an image to post")
            return
        }

        // A caption is required

        if caption.text.isEmpty {
            displayAlert("The caption is empty", message: "You must enter a caption for the image")
            return
        }

        // Set up a spinny thing to show we're busy

        indicator = UIActivityIndicatorView(frame: self.view.frame)

        indicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)     // Grey out the background
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray

        view.addSubview(indicator)
        indicator.startAnimating()

        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        // Create a Post record with the caption and image file.

        var post = PFObject(className: "Post")

        post["caption"] = caption.text
        post["userId"]  = PFUser.currentUser()?.objectId

        let imageData = UIImagePNGRepresentation(imageToPost.image)
        let imageFile = PFFile(name: "image.png", data: imageData)

        post["imageFile"] = imageFile

        // Post it and start listening to the user again

        post.saveInBackgroundWithBlock {
            (success, error) -> Void in

            if error == nil {
                self.displayAlert("Image Posted", message: "Your image has been posted successfully")
                self.imageToPost.image = UIImage(named: "placeholder.png")
                self.caption.text = ""
            }
            else {
                self.displayAlert("Could not post image", message: error!.localizedDescription)
            }

            self.indicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }

    /////////////
    // Display an alert

    func displayAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            (action) -> Void in

            self.dismissViewControllerAnimated(true, completion: nil)
        }))

        self.presentViewController(alert, animated: true, completion: nil)
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
