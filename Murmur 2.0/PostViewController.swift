//
//  MurmurViewController.swift
//  Murmur
//
//  Created by irving fierro on 28/10/16.
//  Copyright © 2016 Murmur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GeoFire
import CoreLocation

class MurmurViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet var TittleTextField: UITextField!
    
    @IBOutlet var ContentTextField: UITextView!
    
    var imageFileName = ""
    
    @IBOutlet var previewdelaimagen: UIImageView!
    @IBOutlet var selectimageButton: UIButton!
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func PublicadBoton(_ sender: AnyObject) {
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            if let title = TittleTextField.text {
                if let content = ContentTextField.text {
                    let postObject: Dictionary<String, Any> = [
                        "uid" : uid,
                        "title" : title,
                        "content" : content,
                        "image" :imageFileName
                    ]
                
                    // get user location (latitude, longitude)
                    
                    
                    let postRef = FIRDatabase.database().reference().child("post").childByAutoId()
                    postRef.setValue(postObject)
                    
                    print("Saved post.")
                    
                    let postID = postRef.key
                    let locationRef = GeoFire(firebaseRef: FIRDatabase.database().reference().child("post_locations"))
                    
                    locationRef?.setLocation(userLocation, forKey: postID, withCompletionBlock: { (error) in
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
                    
                    let alert = UIAlertController(title: "Exito", message: "Tu murmur se a Publicado con exito", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("publicado")
                }
            }
        }
    
    }
    @IBAction func SleccionarImagen(_ sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
    }
    func uploadImage(image: UIImage){
        let randomName = randomStringWithLength(length: 10)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let uploadRef = FIRStorage.storage().reference().child("images/\(randomName).jpg")
        
        let uploadTask = uploadRef.put(imageData!, metadata: nil) { metadata,
            error in
            if error == nil {
                //bien
                print("todo bien perro")
                self.imageFileName = "\(randomName as NSString).jpg"
                
            } else {
                //eror
                print("error subiendo la foto:: \(error?.localizedDescription)")
            }
            
        }
        
    }
    
    func randomStringWithLength(length: Int) -> NSString {
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var randomString: NSMutableString = NSMutableString(capacity: length)
        for i in 0..<length {
            var len = UInt32(characters.length)
            var rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //si le pica a cancelar
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //cuando termine de seleccionar imagen
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage {
            self.previewdelaimagen.image = pickedImage
            self.selectimageButton.isEnabled = false
            self.selectimageButton.isHidden = true
            uploadImage(image: pickedImage)
            picker.dismiss(animated: true, completion: nil)
            
        }
    }
        
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
