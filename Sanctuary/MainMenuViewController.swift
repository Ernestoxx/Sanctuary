//
//  MainMenuViewController.swift
//  Sanctuary
//
//  Created by Andreas Panayi on 4/4/16.
//  Copyright © 2016 AppFanaticz. All rights reserved.
//

import UIKit

var didSignOut: Bool?

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = false
        didSignOut = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //This method ask the user if they want to logout or not if press ok then user backs to login screen 
    @IBAction func logOut(sender: UIButton) {
        didSignOut = true
        
        let alert = UIAlertController(title: "Log Out", message: "Do you want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "Yes", style: .Default) { _ in
            let viewControllerYouWantToPresent = self.storyboard?.instantiateViewControllerWithIdentifier("LogIn")
            self.presentViewController(viewControllerYouWantToPresent!, animated: true, completion: nil)
        }
        
        let action2 = UIAlertAction(title: "No", style: .Default) { _ in
        
        }
        
        alert.addAction(action)
        alert.addAction(action2)
        
        self.presentViewController(alert, animated: true){}
    }
}