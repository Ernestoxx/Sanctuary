//
//  ExistingProjectsViewController.swift
//  Sanctuary
//
//  Created by Andreas Panayi on 4/8/16.
//  Copyright © 2016 AppFanaticz. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class ExistingProjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var people = [NSManagedObject]()
    var projectNameForEmail: String!
    var usernameEmail: String!
    var projectIcon: NSData!
    var information: NSData?
    var tappedButtonTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Existing Projects"
        
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "backgroundImage")
        self.tableView.backgroundView = imageView
        fetchAllProjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This method pass the image and project name to update the project.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let object = people[((tableView.indexPathForCell(sender as! ProjectNameCC))?.row)!] as NSManagedObject
        
        let destinationVC = segue.destinationViewController as! OrthoPhotoViewController
        
        //Send the information of each cell to the next screen to be edited
        destinationVC.newImage = UIImage(data: object.valueForKey("image") as! NSData)
        destinationVC.projectName = object.valueForKey("name") as? String
        destinationVC.desc = object.valueForKey("desc") as? String //work on it
        destinationVC.isUpdate = true
        destinationVC.textUpdated = true
    }
    
    //This fetch all the saved projects and display in list.
    func fetchAllProjects() {
        //Fetch all projects as a Managed Object.
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext

        let request = NSFetchRequest(entityName: "Projects")
        
        do {
            //Create list of projects from object
            var peopleData = try context.executeFetchRequest(request) as! [NSManagedObject]
            
            //For loop which reverse the array of projects to display latest project on top
            if peopleData.count > 0 {
                for index in (peopleData.count - 1).stride(through: 0, by: -1) {
                    print("Indexxx \(index)")
                    people.append(peopleData[index])
                }
            }
            
            //Method to display data in list
            self.tableView.reloadData()
        } catch {
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Project", forIndexPath: indexPath) as! ProjectNameCC
        
        let object = people[indexPath.row] as NSManagedObject
 
        cell.imageIcon?.image = UIImage(data: object.valueForKey("image") as! NSData)
        cell.projectName.text = object.valueForKey("name") as? String
        cell.userName.text = object.valueForKey("user") as? String
        cell.export.tag = indexPath.row

        
        if checkIsEmpty(object.valueForKey("lastupdate")!) == false && object.valueForKey("user") as? String != object.valueForKey("lastupdate") as? String  {
            cell.updateUser.text = "Last updated by \(object.valueForKey("lastupdate") as! String)"
        } else {
            cell.updateUser.text = ""
        }

        return cell
    }
    
    //Method which open the screen to update the saved project
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("OpenEditImageView", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func checkIsEmpty(str: AnyObject) -> Bool
    {
        if (str as! NSObject == NSNull() || str as! String == "")
        {
            return true
        }
        return false
    }
    
    @IBAction func export(sender: UIButton) {
        self.tappedButtonTag = sender.tag
        print(tappedButtonTag)
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }

        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        //get all the object from people and set it to setObject
        let setObject = self.people[self.tappedButtonTag] as NSManagedObject
        projectNameForEmail = setObject.valueForKey("name") as? String
        projectIcon = setObject.valueForKey("image") as! NSData
        information = setObject.valueForKey("information") as? NSData

        
        /*
         use this if you want to set the usernameEmail to 
         the name that says under the project name
         usernameEmail = setObject.valueForKey("user") as? String
        */
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mailComposerVC = MFMailComposeViewController()
        // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([appDelegate.currentUser as String])
        mailComposerVC.setSubject(projectNameForEmail)
        mailComposerVC.setMessageBody("", isHTML: false)
        mailComposerVC.addAttachmentData(projectIcon, mimeType: "image/jpeg", fileName: projectNameForEmail + ".jpeg")
        mailComposerVC.addAttachmentData(information!, mimeType: "text/msword", fileName: "information.doc")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    //MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}