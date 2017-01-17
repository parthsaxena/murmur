//
//  InicioViewController.swift
//  Murmur
//
//  Created by irving fierro on 13/11/16.
//  Copyright © 2016 Murmur. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import SDWebImage
import GeoFire

class InicioViewController: UITableViewController, CLLocationManagerDelegate {
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var loggedInUserData:NSDictionary?

    
    @IBOutlet var InicioTableView: UITableView!
    
    var defaultImageViewHeightConstraint:CGFloat = 78.0
    
    var loadedPosts = false
    
    var Murmurs = [NSDictionary]()
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocation!

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location
        if !loadedPosts {
            // we need to load the posts
            //get the logged in users details
            self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                
                //store the logged in users details into the variable
                self.loggedInUserData = snapshot.value as? NSDictionary
                
                
                //get all the tweets that are made by the user
                
                let geoFire = GeoFire(firebaseRef: FIRDatabase.database().reference().child("MurmursLocations"))
                let query = geoFire?.query(at: self.userLocation, withRadius: 5.0)
                print("Current user location: latitude: \(self.userLocation.coordinate.latitude), longitude: \(self.userLocation.coordinate.longitude)")
                query?.observe(GFEventType.keyEntered, with: { (key, location) in
                    print("Key '\(key)' entered the search area and is at location '\(location)")
                    let actualKey = key! as String
                    let newRef = FIRDatabase.database().reference().child("Murmurs").child(actualKey)
                    newRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        print("appended one value")
                        self.Murmurs.append(snapshot.value as! NSDictionary)
                        self.InicioTableView.insertRows(at: [IndexPath(row:0,section:0)], with: UITableViewRowAnimation.automatic)
                    })
                    
                })
                
                /*self.databaseRef.child("Murmurs").child(self.loggedInUser!.uid).observe(.childAdded, with: { (snapshot:FIRDataSnapshot) in
                 
                 
                 self.Murmurs.append(snapshot.value as! NSDictionary)
                 
                 
                 self.InicioTableView.insertRows(at: [IndexPath(row:0,section:0)], with: UITableViewRowAnimation.automatic)
                 
                 
                 
                 }){(error) in
                 
                 print(error.localizedDescription)
                 }*/
                
            }
            loadedPosts = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        self.InicioTableView.rowHeight = UITableViewAutomaticDimension
        self.InicioTableView.estimatedRowHeight = 138
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Murmurs.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InicioViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "InicioViewTableViewCell", for: indexPath) as! InicioViewTableViewCell

        print("MURMURS: \(Murmurs)")
        
        let Murmur = Murmurs[(self.Murmurs.count-1) - (indexPath.row)]["text"] as! String
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapMediaInMurmur(_:)))
        
        cell.MurmurImage.addGestureRecognizer(imageTap)
        
        if(Murmurs[(self.Murmurs.count-1) - (indexPath.row)]["picture"] != nil)
        {
            
            
            
            cell.MurmurImage.isHidden = false
            cell.ImageViewHeightConstraint.constant = defaultImageViewHeightConstraint
            
            let picture = Murmurs[(self.Murmurs.count-1) - (indexPath.row)]["picture"] as! String
            
            let url = URL(string:picture)
            cell.MurmurImage.layer.cornerRadius = 10
            cell.MurmurImage.layer.borderWidth = 3
            cell.MurmurImage.layer.borderColor = UIColor.white.cgColor
            cell.MurmurImage!.sd_setImage(with: url, placeholderImage: UIImage(named:"murmurGRANDE")!)
        
        }
        else
        {
            cell.MurmurImage.isHidden = true
            cell.ImageViewHeightConstraint.constant = 0
            
        }

        
        
        cell.configure(Murmur)
        
        
        return cell
    }
    
    
    func didTapMediaInMurmur(_ sender:UITapGestureRecognizer)
        {
            
        self.InicioTableView.isScrollEnabled = false
        
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        
        newImageView.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.frame.width)!, height: (UIApplication.shared.keyWindow?.frame.height)!)
        
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        
        newImageView.isUserInteractionEnabled = true
        
        
            
        let tap = UITapGestureRecognizer(target:self,action:#selector(self.dismissFullScreenImage))
        
        newImageView.addGestureRecognizer(tap)
        
        print("Z-POSITION: \(self.navigationController?.navigationBar.layer.zPosition)")
        self.navigationController?.navigationBar.layer.zPosition = -1
        UIApplication.shared.keyWindow?.addSubview(newImageView)
        
    }
    
    func dismissFullScreenImage(_ sender:UITapGestureRecognizer)
    {
        self.InicioTableView.isScrollEnabled = true
        self.navigationController?.navigationBar.layer.zPosition = 0
        sender.view?.removeFromSuperview()
    }

    
}
