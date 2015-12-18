//
//  ViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func takePhotoTapped() {
        let picker = UIImagePickerController.init()
        picker.sourceType = .Camera
        presentPicker(picker)
    }
    
    @IBAction func choosePhotoTapped() {
        let picker = UIImagePickerController.init()
        picker.sourceType = .PhotoLibrary
        presentPicker(picker)
    }
    
    func presentPicker(picker: UIImagePickerController) {
        picker.allowsEditing = false
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("editImageSegue", sender: info[UIImagePickerControllerOriginalImage] as! UIImage)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editImageSegue") {
            let nextController:ImageEditingViewController = segue.destinationViewController as! ImageEditingViewController
            nextController.uneditedImage = sender as! UIImage
        }
    }
}

