//
//  LogInViewController.swift
//  Sanctuary
//
//  Created by Andreas Panayi on 4/3/16.
//  Copyright © 2016 AppFanaticz. All rights reserved.
//

import UIKit
import CoreData

class LogInViewController: UIViewController {

    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var passwordLogin: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signOut()
        
        //create a gesture recognizer so when user touches anywhere in the screen this will be used
        //to hide the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    //Method to dismiss keyboard when the screen is touched
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //Method to dismiss keyboard when the return key is pressed
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //Recognizes enter key in keyboard
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Method which do the Login task
    @IBAction func loginButton(sender: UIButton) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        //This condition check if email or password is empty then display alert message
        if login.text == "" || passwordLogin.text == "" {
            let alert = UIAlertController(title: "User Registration Alert", message: "Please fill all the fields", preferredStyle: UIAlertControllerStyle.Alert)
            
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
            
            }
            
            alert.addAction(action)
            
            self.presentViewController(alert, animated: true){}
        } else {
            //If both field is not empty then first check entered user is exist if yes then do the login task otherwise first register the user then login.
            let request = NSFetchRequest(entityName: "Users")
            request.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "email == %@", login.text!)
            request.predicate = predicate

            do {
                let results = try context.executeFetchRequest(request)
                
                if results.count > 0 {
                
                    for result in results as! [NSManagedObject] {
                        print("user exists")
                        print(result.valueForKey("email")!)
                        print(result.valueForKey("password")!)

                    }
                } else {
                    let newUser = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: context) as NSManagedObject
                    
                    newUser.setValue("" + login.text!, forKey: "email")
                    newUser.setValue("" + passwordLogin.text!, forKey: "password")
                    
                    do {
                        try context.save()
                    } catch {
                        print("Problem")
                    }
                    
                    print("New user created")
                    print(newUser.valueForKey("email")!)
                    print(newUser.valueForKey("password")!)
                }
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.currentUser = login.text!
            } catch {
                print("Cant fetch")
            }
        }
    }
    
    func signOut() {
        if didSignOut == true {
            self.navigationItem.hidesBackButton = true
        }
    }
    
    //MARK: - UITextViewDelegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}