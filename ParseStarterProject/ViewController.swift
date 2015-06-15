//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    var activityIndicator = UIActivityIndicatorView()
    var signupActive = true

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var registered: UILabel!

    @IBOutlet weak var action: UIButton!
    @IBOutlet weak var swap: UIButton!

    /////////////////
    // Signup / Login button pressed

    @IBAction func actionPressed(sender: AnyObject) {
        if username.text == "" || password.text == "" {
            displayAlert("Error in Form", message: "You must enter a user name and a password")
        }
        else {
            // Show a spinner while we're signing the user up

            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray

            // Show the spinner and ignore the UI temporarily

            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()

            var errorMessage = "Please try again later."

            if signupActive {
                var user = PFUser()

                user.username = username.text
                user.password = password.text

                user.signUpInBackgroundWithBlock({
                    (success, error) -> Void in

                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()

                    if success {
                        self.performSegueWithIdentifier("Login", sender: self)
                    }
                    else {
                        if let errorString = error!.userInfo?["error"] as? String {
                            errorMessage = errorString
                        }

                        self.displayAlert("Signup Unsuccessful", message: errorMessage)
                    }
                })
            }
            else {
                PFUser.logInWithUsernameInBackground(username.text, password: password.text, block: {
                    (user, error) in

                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()

                    if user != nil {
                        self.performSegueWithIdentifier("Login", sender: self)
                    }
                    else {
                        if let errorString = error!.userInfo?["error"] as? String {
                            errorMessage = errorString
                        }

                        self.displayAlert("Login Unsuccessful", message: errorMessage)
                    }
                })
            }
        }

    }

    /////////////
    // swap operation button pressed

    @IBAction func swapPressed(sender: AnyObject) {
        if signupActive {
            action.setTitle("Log in", forState: .Normal)
            registered.text = "Not Registered?"
            swap.setTitle("Sign up", forState: .Normal)

            signupActive = false
        }
        else {
            action.setTitle("Sign up", forState: .Normal)
            registered.text = "Already Registered?"
            swap.setTitle("Log in", forState: .Normal)

            signupActive = true
        }
    }

    /////////////
    // Display an alert

    func displayAlert(title: String, message: String ) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            (action) in

            self.dismissViewControllerAnimated(true, completion: nil)
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    ///////////////
    // Go straight to the user list if a user is logged in. This can't be done in viewDidLoad()
    // because the Segues have not been set up by that point.
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("Login", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

