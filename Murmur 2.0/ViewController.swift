//
//  ViewController.swift
//  Murmur
//
//  Created by irving fierro on 23/10/16.
//  Copyright © 2016 Murmur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

//  import FBSDKLoginKit
import FirebaseDatabase


class ViewController: UIViewController,  UITextFieldDelegate  {
    
    
    
    var activeField: UITextField?
//  FBSDKLoginButtonDelegate,
    

    @IBOutlet var Scrollview: UIScrollView!
   
    @IBOutlet var murmurGRANDE: UIImageView!
    @IBOutlet var TextUsuario: UITextField!
    @IBOutlet var ContrasenaText: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.TextUsuario.delegate = self
        self.ContrasenaText.delegate = self
        
   
    }

        // Do any additional setup after loading the view, typically from a nib.
       /* let loginButton = FBSDKLoginButton()
        
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x:36, y:345, width: view.frame.width - 70, height:50 )
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
      
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Se cerro la sesion de Facebook ")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
            
        }
        
        showEmailAddress()
        
    }
    
    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else
        { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil{
                print("algo malo paso con el usuario de FB", error)
                return
            }
            
            print("se inicio sesion todo bien con el usuario", user)
        
            
        })
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            
            if err != nil{
                print("fallo request de la grafica", err)
                return
            }
            
            print(result)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "inicioVC")
            self.present(vc!, animated: true, completion: nil)
            
            
            
        }*/

      
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //checar si el usuario ya inicio sesion
        if FIRAuth.auth()?.currentUser != nil {
            //ya esta dentro 
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "inicioVC")
            self.present(vc!, animated: false, completion: nil)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
   
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(ContrasenaText: UITextField!) -> Bool {
        ContrasenaText.resignFirstResponder()
        return true;
        
    }
    
    func textFieldShouldReturn(TextUsuario: UITextField!) -> Bool {
        TextUsuario.resignFirstResponder()
        return true;
    }
    */

    @IBAction func IniciarSesionboton(_ sender: AnyObject) {
        
        let username = TextUsuario.text
        let password = ContrasenaText.text
        
        FIRAuth.auth()?.signIn(withEmail: username!, password: password!, completion: { (user, error) in
            if error != nil{
                //error con el usuario
                let alert = UIAlertController(title: "Error", message: "Usuario/Password Incorrectas", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                //exito
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "inicioVC")
                self.present(vc!, animated: true, completion: nil)
                
            
                
               
                
                
                
            }
        })
    
        
      /*  FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            if user != nil{
                
                print("user is signed in")
                
                //send the user to the homeViewController
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name:"Inicio",bundle:nil)
                
                let InicioViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "InicioVC")
                
                //send the user to the homescreen
                self.present(InicioViewController, animated: true, completion: nil)
                
            }
            
        })
 */
    
    }
    
    

}

