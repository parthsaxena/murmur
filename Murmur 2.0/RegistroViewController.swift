//
//  RegistroViewController.swift
//  Murmur
//
//  Created by irving fierro on 26/10/16.
//  Copyright © 2016 Murmur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegistroViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var UsuarioText: UITextField!
    @IBOutlet var PasswordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UsuarioText.delegate = self
        self.PasswordText.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func CrearCuenta(_ sender: AnyObject) {
        
        let username = UsuarioText.text
        let password = PasswordText.text
        
        FIRAuth.auth()?.createUser(withEmail: username!, password: password!, completion: { (user, error) in
            if error != nil {
                //error al crear cuenta
                let alert = UIAlertController(title: "Error", message: "Error creando la cuenta", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                //exito
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "postVC")
                self.present(vc!, animated: true, completion: nil)
            }
        })
        
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
