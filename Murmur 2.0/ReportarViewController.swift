//
//  ReportarViewController.swift
//  Murmur
//
//  Created by irving fierro on 29/11/16.
//  Copyright © 2016 Murmur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ReportarViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate  {
    
    
    
    @IBOutlet var NuevoreporteTextField: UITextView!
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        NuevoreporteTextField.textContainerInset = UIEdgeInsetsMake(30, 20, 20, 20)
        
        NuevoreporteTextField.text = "     |"
        NuevoreporteTextField.textColor = UIColor.lightGray
        
        // Do any additional setup after loading the view.
        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            NuevoreporteTextField.text = ""
            return true
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapequis(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(NuevoreporteTextField.textColor == UIColor.lightGray)
        {
            NuevoreporteTextField.text = ""
            NuevoreporteTextField.textColor = UIColor.black
            
        }
    }
  

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    
    
    func didTapReportar(_ sender: AnyObject) {
        if(NuevoreporteTextField.text.characters.count>0)
        {
            let key = self.databaseRef.child("Reportes").childByAutoId().key
            
            let childUpdates = ["/Reportes/\(self.loggedInUser!.uid!)/\(key)/text":self.NuevoreporteTextField.text,
                                "/Reportes/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)"] as [String : Any]
            self.databaseRef.updateChildValues(childUpdates)
            
            dismiss(animated: true, completion: nil)
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
