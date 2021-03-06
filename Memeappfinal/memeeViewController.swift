//
//  ViewController.swift
//  Memeappfinal
//
//  Created by Vidya Durvasula on 8/29/17.
//  Copyright © 2017 Vidya Durvasula. All rights reserved.
//

import UIKit

class MemeeViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    @IBOutlet weak var imagepick: UIImageView!
    @IBOutlet weak var Toptext: UITextField!
    
    @IBOutlet weak var bottom: UITextField!
    
    @IBOutlet weak var camerabutton: UIBarButtonItem!
    
    @IBOutlet weak var Toptoolbar: UIToolbar!
    
    
    @IBOutlet weak var bottomtoolbar: UIToolbar!
    
    
    @IBOutlet weak var cancel: UIBarButtonItem!
    
    @IBOutlet weak var sharebutton: UIBarButtonItem!
    
    
    @IBAction func shareaction(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activeController = UIActivityViewController( activityItems: [memedImage], applicationActivities: nil )
        
        activeController.completionWithItemsHandler =
            {
                activityType, completion, items, error in
                
                if completion
                {
                    
                    self.save( memedImage: memedImage )
                }
                
                self.dismiss( animated: true, completion: nil )
        }
        
        present( activeController, animated: true, completion: nil )
    }
    var isEditMode: Bool! = false
    var memeToBeEdited: Meme!
    
    func generateMemedImage() -> UIImage {
        
        // Render view to an imag
        self.Toptoolbar.isHidden = true
        self.bottomtoolbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.Toptoolbar.isHidden = false
        self.bottomtoolbar.isHidden = false
        return memedImage
    }
    
    func save(memedImage: UIImage) {
        let contextMemedImage = generateMemedImage()
        // Create the meme
        let meme = Meme(topText: Toptext.text!, bottomText : bottom.text!, origImage: imagepick.image!, memedImage:contextMemedImage )
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    
    @IBAction func cancelaction(_ sender: Any) {
        
        Toptext.text = "TOP"
        bottom.text = "BOTTOM"
        imagepick.image = nil
        sharebutton.isEnabled = false
    }
    
    @IBAction func choosealbum(_ sender: Any) {
        pickImageforalbum(sourceType: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func choosecamera(_ sender: Any) {
        pickImageforalbum(sourceType: UIImagePickerControllerSourceType.camera)
    }
    // User actually picked an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imagepick.contentMode = .scaleAspectFit
            imagepick.image = image
            
            cancel.isEnabled = true
            sharebutton.isEnabled = true
        }
        
        dismiss( animated: true, completion: nil )
    }
    
    
    func pickImageforalbum ( sourceType: UIImagePickerControllerSourceType )
    {
        
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        imagepick.contentMode = .scaleAspectFit
        self.present( pickerController, animated: true, completion: nil )
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        //  let userInfo = notification.userInfo
        let keyboardBeginFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let screenHeight = UIScreen.main.bounds.height
        let isBeginOrEnd = keyboardBeginFrame.origin.y == screenHeight || keyboardEndFrame.origin.y == screenHeight
        let heightOffset = keyboardBeginFrame.origin.y - keyboardEndFrame.origin.y - (isBeginOrEnd ? bottomLayoutGuide.length : 0)
        return heightOffset
    }
    
    
    func keyboardWillShow(_ notification:Notification) {
        if bottom.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    func keyboardWillHide(notification: NSNotification){
        if self.view.frame.origin.y != 0{
            view.frame.origin.y += getKeyboardHeight(notification as Notification)
            
        }
        
    }
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        camerabutton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (Toptext == textField) {
            Toptext.text = ""}
        if (bottom == textField) {
            bottom.text = ""
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.frame.origin.y = 0
        textField.resignFirstResponder()
        return true
    }
    func hideKeyboardWhenTappedAround() {
        view.frame.origin.y = 0
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MemeeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.frame.origin.y = 0
        view.endEditing(true)
    }
    
    
    func initialsetup(textfield:UITextField, initialtext: String, delegate:UITextFieldDelegate){
        textfield.text = initialtext
        textfield.delegate = delegate
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sharebutton.isEnabled = false
        cancel.isEnabled = false
        imagepick.contentMode = .scaleAspectFit
        initialsetup(textfield: Toptext, initialtext: "Top", delegate:self )
        initialsetup(textfield: bottom, initialtext: "BOTTOM", delegate: self)
        settextattributes(textfield: Toptext)
        settextattributes(textfield: bottom)
        hideKeyboardWhenTappedAround()
       self.navigationController!.navigationBar.topItem!.title = "SentMeme"
        
    }
    
    
}
    


