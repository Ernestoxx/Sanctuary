//
//  OrthoPhotoViewController.swift
//  Sanctuary
//
//  Created by Andreas Panayi on 4/5/16.
//  Copyright © 2016 AppFanaticz. All rights reserved.
//

import UIKit
import CoreData

var project: NSManagedObject!

class OrthoPhotoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var orthoPhoto: UIImageView!
    @IBOutlet weak var secondOrthoPhoto: UIImageView!    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var marrLineData = NSMutableArray()
    var startPoint = CGPoint.zero
    var lastPoint = CGPoint.zero
    var swiped = false
    
    var newImage: UIImage?
    var lineImage: UIImage?
    var projectName: NSString!
    var rightBarButtonItem: UIBarButtonItem!
    var data: NSData?
    var information: NSData?
    var desc: String?
    
    var shapeType = 0;
    
    var isUpdate = false
    var textUpdated = false
    var isFirstPolygon = true
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = projectName as String
        
        orthoPhoto.image = newImage
        
        //set the delegate so we can use it when 
        //the user presses enter to hide the keyboard
        descriptionTextView.delegate = self
        
        //Used to move screen up when the keyboard is shown
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrthoPhotoViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrthoPhotoViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    //Method to move the screen up when the keyboard is shown
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    //Method to move the screen down when the keyboard is dismissed
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
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
    
    //Method to select line to draw on image
    @IBAction func btnLineClicked(sender: UIButton) {
        shapeType = 1
        descriptionTextView.hidden = true
        print(1)
        
    }
    
    //Method to select Square to draw on image
    @IBAction func btnSquareClicked(sender: UIButton) {
        shapeType = 2
        descriptionTextView.hidden = true
        print(2)

    }
    
    //Method to select Circle to draw on image
    @IBAction func btnCircleClicked(sender: UIButton) {
        shapeType = 3
        descriptionTextView.hidden = true
        print(3)

    }
    
    //Method to select Polygon to draw on image
    @IBAction func btnPolygonClicked(sender: UIButton) {
        isFirstPolygon = true
        shapeType = 4
        descriptionTextView.hidden = true
        print(4)

    }
    
    @IBAction func description(sender: UIButton) {
        
        descriptionTextView.hidden = false
        
        //If true
        if textUpdated {
            //Update the description text to be whatever was passed from the previous 
            //view controller
            descriptionTextView.text = desc
            
        }

    }
    
    
    //Method which update or save the image after adding shape on it.
    @IBAction func btnSaveClicked(sender: UIButton) {
        descriptionTextView.hidden = true
        textUpdated = true

        //this merge the shape on image and generate the single image
        //Make shape image background color transparent
        orthoPhoto.superview?.backgroundColor = UIColor.clearColor()
        var layer = CALayer()
        layer = (orthoPhoto.superview?.layer)!
        
        //Start the context to generate the image of shape
        UIGraphicsBeginImageContext(orthoPhoto.superview!.bounds.size)
        //Make rectangle from which to generate image
        CGContextClipToRect(UIGraphicsGetCurrentContext(), (orthoPhoto.superview?.frame)!)
        //Rander image in layer to generate image
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        //Generate image from context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //End context which we start to generate image
        UIGraphicsEndImageContext()
        
        //Method which save the image to gallery
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        if isUpdate {
            //This method update the exist project with new image data
            //First fetch project data base on name and image to fetch single data.
            let request = NSFetchRequest(entityName: "Projects")
            request.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "name == %@ AND image == %@", projectName, NSData(data: UIImagePNGRepresentation(newImage!)!))
            request.predicate = predicate
            
            do {
                let results = try context.executeFetchRequest(request)
                
                if results.count > 0 {
                    //Set updated image and update the project again.
                    let updateObject = results[0] as! NSManagedObject
                    data = NSData(data: UIImagePNGRepresentation(image!)!)
                    updateObject.setValue(data, forKey: "image")
                    
                    //Convert the updated description text to data and then set the value
                    information = descriptionTextView.text.dataUsingEncoding(NSUTF8StringEncoding)
                    project!.setValue(information, forKey: "information")

                    //Set the value of the desc to be the updated description text
                    updateObject.setValue(descriptionTextView.text, forKey: "desc")
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    updateObject.setValue(appDelegate.currentUser, forKey: "lastupdate")
                }
            } catch {
                
            }
        } else {
            //This method generate the new project and save the image and name data.
            let request = NSFetchRequest(entityName: "Projects")
            request.returnsObjectsAsFaults = false
            
            //Insert single entity object which create new project
            project = NSEntityDescription.insertNewObjectForEntityForName("Projects", inManagedObjectContext: context) as NSManagedObject
            
            //Set image data and project name and user
            data = NSData(data: UIImagePNGRepresentation(image!)!)
            project!.setValue(data, forKey: "image")
            project!.setValue(projectName!, forKey: "name")
            
            //Convert the description text to data and then set the value
            information = descriptionTextView.text.dataUsingEncoding(NSUTF8StringEncoding)
            project!.setValue(information, forKey: "information")
    
            //Set the value of the desc to be the description text
            project!.setValue(descriptionTextView.text, forKey: "desc")
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            project!.setValue(appDelegate.currentUser, forKey: "user")
            project!.setValue("", forKey: "lastupdate")
        }
        
        do {
            //Save context to save Core Data
            try context.save()
        } catch {
            print("Problem")
        }
        
        let alert = UIAlertController(title: "", message: "Project Save Successfully", preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "Ok", style: .Default) { _ in
            if let viewControllers = self.navigationController?.viewControllers {
                for viewController in viewControllers {
                    if viewController.isKindOfClass(MainMenuViewController) {
                        self.navigationController?.popToViewController(viewController, animated: true)
                    }
                }
            }
        }
        
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true){}
    }
    
    //Method which detect the touch begin in view and set the start point to draw any shape.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            //Set start point when touch began
            startPoint = touch.locationInView(secondOrthoPhoto)
            if shapeType == 4 {
                //If polygon is selected then base on touch draw line between two points
                if isFirstPolygon == true {
                    lastPoint = startPoint
                    isFirstPolygon = false
                }
                drawShapeFromToPoint(startPoint, toPoint: lastPoint)
            } else {
                lastPoint = startPoint
            }
        }
    }
    
    //Method which detect the movement of touch on screen and draw the shape base on touch movement
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(secondOrthoPhoto)
            if shapeType != 4 {
                //Draw shape base on touch point
                drawShapeFromToPoint(startPoint, toPoint: currentPoint)
            }
            lastPoint = currentPoint
        }
    }
    
    //Method which detect the touch end in view and set the end point to draw any shape.
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if !swiped {
            drawShapeFromToPoint(startPoint, toPoint: lastPoint)
        }
        
        if shapeType == 4 {
            //When polygon is selected draw line between start and end point
            drawShapeFromToPoint(startPoint, toPoint: lastPoint)
            if let touch = touches.first {
                let currentPoint = touch.locationInView(secondOrthoPhoto)
                lastPoint = currentPoint
            }
        }
        
        //Set the generated image of shape to draw on image on next touch begin
        lineImage = secondOrthoPhoto.image
    }
    
    //Method which draw the selected shape between start and end point on image
    func drawShapeFromToPoint(fromPoint: CGPoint, toPoint: CGPoint) {
        //Start the context to draw shape
        UIGraphicsBeginImageContext(secondOrthoPhoto.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        //Draw the last added shape image
        if lineImage != nil {
            lineImage!.drawInRect(CGRectMake(0, 0, secondOrthoPhoto.frame.size.width, secondOrthoPhoto.frame.size.height))
        }
        
        //Draw the line, rectangle, circle as per selection
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        if shapeType == 1 {
            //Draw line when line is selected
            CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        } else if shapeType == 2 {
            //Draw rectangle when square is selected
            CGContextAddRect(context, CGRectMake(startPoint.x, startPoint.y, lastPoint.x - startPoint.x, lastPoint.y - startPoint.y))
        } else if shapeType == 3 {
            //Draw circle when circle is selected
             CGContextAddEllipseInRect(context, CGRectMake(startPoint.x, startPoint.y, lastPoint.x - startPoint.x, lastPoint.y - startPoint.y));
        } else if shapeType == 4 {
            //Draw line between two point to create polygon.
            CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
            CGContextSetFillColor(context, CGColorGetComponents(UIColor.redColor().CGColor))
        }
        
        //Set the cap of line to round
        CGContextSetLineCap(context, CGLineCap.Round)
        //Set the line width
        CGContextSetLineWidth(context, 3)
        //Set the color of line
        CGContextSetRGBStrokeColor(context, 255, 0, 0, 1.0)
        //Set the blend mode of context to Normal
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        //Set the path of the context
        CGContextStrokePath(context)
        
        //Generate the image of shape which is added on image.
        secondOrthoPhoto.image = UIGraphicsGetImageFromCurrentImageContext()
        
        //End the current context
        UIGraphicsEndImageContext()
    }
}