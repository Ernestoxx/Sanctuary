//
//  CreateNewProjectViewController.swift
//  Sanctuary
//
//  Created by Andreas Panayi on 4/4/16.
//  Copyright © 2016 AppFanaticz. All rights reserved.
//

import UIKit

class CreateNewProjectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var newProjectName: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Create New Project"
        
        imagePicker.delegate = self
        
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
    
    //This method open the gallery of iphone to choose image from that gallery
    @IBAction func importImage(sender: UIButton) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - UIImagePickerControllerDelegate Methods
    //After selecting image from gallery this delegate method calls from here we can get the selected image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image.contentMode = .ScaleAspectFit
            image.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //This method calls when we close the image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Navigation
    //This method called when we open the screen to add line, square all that shape from this method we can pass the project name and selected image to next screen. 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if newProjectName.text == "" || image.image == nil {
            let alert = UIAlertController(title: "Empty Fields", message: "Please set a name for you project and select an image from the library", preferredStyle: UIAlertControllerStyle.Alert)
            
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
            }
            
            alert.addAction(action)
            
            self.presentViewController(alert, animated: true){}
        } else {
            
            let destinationVC = segue.destinationViewController as! OrthoPhotoViewController
            
            destinationVC.newImage = image.image
            destinationVC.projectName = newProjectName.text
        }
    }
    
    //MARK: - UITextViewDelegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}