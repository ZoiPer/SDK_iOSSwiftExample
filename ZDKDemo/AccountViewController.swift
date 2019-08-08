//
//  FirstViewController.swift
//  ZDKDemo
//
//  Copyright © 2019 Securax. All rights reserved.
//

import UIKit

var accountViewController : AccountViewController?

class AccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activationUsername: UITextField?
    @IBOutlet weak var activationPassword: UITextField?
    
    @IBOutlet weak var accountDomain:   UITextField?
    @IBOutlet weak var accountUsername: UITextField?
    @IBOutlet weak var accountPassword: UITextField?
    
    @IBOutlet weak var btnRegister: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        accountViewController = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc
    func changeRegisterButtonTitleTo(_ title: String) {
        print("New (register) button title: '\(title)'")
        btnRegister?.setTitle(title, for: .normal)
        btnRegister?.setTitle(title, for: .highlighted)
        btnRegister?.setTitle(title, for: .selected)
        btnRegister?.setTitle(title, for: .disabled)
    }
    
    @IBAction func activateTapped(_ sender: Any) {
        guard activationUsername != nil else {
            appLogger.logError(.lf_UI, message: "Activation user name text field is nil.")
            return
        }
        
        guard activationPassword != nil else {
            appLogger.logError(.lf_UI, message: "Activation password text field is nil.")
            return
        }
        
        if activationUsername!.text!.count == 0 || activationPassword!.text!.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Empty user name and/or password.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                return
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.contextManager.activateZDK(zdkVersion, withUserName: activationUsername!.text!, andPassword: activationPassword!.text!)
    }
    
    @IBAction func registerTapped(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if !appDelegate.contextManager.context.activation.activated {
            let alert = UIAlertController(title: "Error", message: "ZDK is not activated.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                return
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard accountDomain != nil else {
            appLogger.logError(.lf_UI, message: "Account domain text field is nil.")
            return
        }
        
        guard accountUsername != nil else {
            appLogger.logError(.lf_UI, message: "Account user name text field is nil.")
            return
        }
        
        guard accountPassword != nil else {
            appLogger.logError(.lf_UI, message: "Account password text field is nil.")
            return
        }
        
        if accountDomain!.text!.count == 0 || accountUsername!.text!.count == 0 || accountPassword!.text!.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Some fields are not filled in.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                return
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        appDelegate.contextManager.registerAccountWithDomain(accountDomain!.text!, username: accountUsername!.text!, andPassword: accountPassword!.text!)
    }
}

