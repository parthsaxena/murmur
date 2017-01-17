//
//  NuevoMurmurViewController.swift
//  Murmur
//
//  Created by irving fierro on 13/11/16.
//  Copyright © 2016 Murmur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import GeoFire

class NuevoMurmurViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet var NuevoMurmurTextView: UITextView!
    
    @IBOutlet var NuevoMurmurToolbar: UIToolbar!
    
    @IBOutlet var ToolbarBottomConstraint: NSLayoutConstraint!
    var  ToolBarBottomConstrainInitialValue = CGFloat()
    //referencia a firebase
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var imagepicker = UIImagePickerController()
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.NuevoMurmurToolbar.isHidden = true
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        NuevoMurmurTextView.textContainerInset = UIEdgeInsetsMake(30, 20, 20, 20)
        
        NuevoMurmurTextView.text = "   |"
        NuevoMurmurTextView.textColor = UIColor.lightGray

        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location
        print("locations = \(userLocation.coordinate.latitude) \(userLocation.coordinate.longitude)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        enableKeyboardHideOnTap()
        
        self.ToolBarBottomConstrainInitialValue = ToolbarBottomConstraint.constant
    }

    
    fileprivate func enableKeyboardHideOnTap(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(NuevoMurmurViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NuevoMurmurViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NuevoMurmurViewController.hideKeyboard))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let info = (notification as NSNotification).userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            
            self.ToolbarBottomConstraint.constant = keyboardFrame.size.height
            
            self.NuevoMurmurToolbar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            
            self.ToolbarBottomConstraint.constant = self.ToolBarBottomConstrainInitialValue
            
            self.NuevoMurmurToolbar.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCancel(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(NuevoMurmurTextView.textColor == UIColor.lightGray)
        {
            NuevoMurmurTextView.text = ""
            NuevoMurmurTextView.textColor = UIColor.black
        
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    

     func didTapMurmur(_ sender: AnyObject) {
        
        var imagesArray = [AnyObject]()
        
        //extract the images from the attributed text
        self.NuevoMurmurTextView.attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, self.NuevoMurmurTextView.text.characters.count), options: []) { (value, range, true) in
            
            if(value is NSTextAttachment)
            {
                let attachment = value as! NSTextAttachment
                var image : UIImage? = nil
                
                if(attachment.image !== nil)
                {
                    image = attachment.image!
                    imagesArray.append(image!)
                }
                else
                {
                    print("No Se Encontro Imagen")
                }
            }
        }
        let MurmurLength = NuevoMurmurTextView.text.characters.count
        let numImages = imagesArray.count
        
        //create a unique auto generated key from firebase database
        let key = self.databaseRef.child("Murmurs").childByAutoId().key
        
        let storageRef = FIRStorage.storage().reference()
        let pictureStorageRef = storageRef.child("user_profiles/\(self.loggedInUser!.uid)/media/\(key)")
        
        //reduce resolution of selected picture
        
        
        //user has entered text and an image
        if(MurmurLength>0 && numImages>0)
        
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            
            let uploadTask = pictureStorageRef.put(lowResImageData!,metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = ["/Murmurs/\(key)/text":self.NuevoMurmurTextView.text,
                                        "/Murmurs/\(key)/timestamp":"\(Date().timeIntervalSince1970)",
                        "/Murmurs/\(key)/picture":downloadUrl!.absoluteString, "/Murmurs/\(key)/uid":self.loggedInUser?.uid] as [String : Any]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                    self.saveLocation(key: key, location: self.userLocation)
                }
                
            }
            dismiss(animated: true, completion: nil)
        }
            //user has entered only text
        else if(MurmurLength>0)
        {
            let childUpdates = ["/Murmurs/\(key)/text":NuevoMurmurTextView.text,
                                "/Murmurs/\(key)/timestamp":"\(Date().timeIntervalSince1970)", "Murmurs/\(key)/uid":self.loggedInUser?.uid] as [String : Any]
            
            self.databaseRef.updateChildValues(childUpdates)
            saveLocation(key: key, location: userLocation)
            
            dismiss(animated: true, completion: nil)
            
        }
        else if(numImages>0)
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            
            let uploadTask = pictureStorageRef.put(lowResImageData!,metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = [
                        "/Murmurs/\(key)/timestamp":"\(Date().timeIntervalSince1970)",
                        "/Murmurs/\(key)/picture":downloadUrl!.absoluteString, "/Murmurs/\(key)/uid":self.loggedInUser?.uid] as [String : Any]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                    self.saveLocation(key: key, location: self.userLocation)
                }
                else
                {
                    print(error?.localizedDescription)
                }
                
            }
            
            dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
    func saveLocation(key: String, location: CLLocation) {
        let locationRef = FIRDatabase.database().reference().child("/MurmursLocations/")
        let geoFire = GeoFire(firebaseRef: locationRef)
        geoFire?.setLocation(location, forKey: key, withCompletionBlock: { (error) in
            if error != nil {
                print("An error occurred while saving the location for the post, \(error?.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Something went wrong while saving your post... Please check back later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.view.tintColor = UIColor.red
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Saved post location.")
            }
        })
    }
    
    @IBAction func SelectImageFromPhotos(_ sender: AnyObject) {
        
        self.imagepicker.delegate = self
        self.imagepicker.sourceType = .savedPhotosAlbum
        self.imagepicker.allowsEditing = true
    
        self.present(self.imagepicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        var attributedString = NSMutableAttributedString()
        
        if(self.NuevoMurmurTextView.text.characters.count>0)
        {
            attributedString = NSMutableAttributedString(string:self.NuevoMurmurTextView.text)
        }
        else
        {
            attributedString = NSMutableAttributedString(string:"\n")
        }
        
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = image
        
        let oldWidth:CGFloat = textAttachment.image!.size.width
        
        let scaleFactor:CGFloat = oldWidth/(NuevoMurmurTextView.frame.size.width-110)
        
        let size = CGSize(width: 30, height: 30)
        
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        attributedString.append(attrStringWithImage)
        
        NuevoMurmurTextView.attributedText = attributedString
        self.dismiss(animated: true, completion: nil)
        
        
        
    }

    
    
    
    
    
    
    
    
    
    
}
