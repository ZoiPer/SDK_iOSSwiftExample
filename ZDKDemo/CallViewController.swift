//
//  CallViewController.swift
//  ZDKDemo
//
//  Copyright © 2019 Securax. All rights reserved.
//

import UIKit

var callViewController : CallViewController?

class CallViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var numberToDial:   UITextField?
    @IBOutlet weak var btnDial:      UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        callViewController = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func dialTapped(_ sender: Any) {
        guard numberToDial != nil else {
            appLogger.logError(.lf_UI, message: "Number to dial text field is nil.")
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.contextManager.isInCall() {
            appLogger.logInfo(.lf_UI, message: "Hanging call up...")
            appDelegate.contextManager.hangupCall()
            return
        }
        
        if numberToDial!.text!.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Cannot dial an empty number.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                return
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        appDelegate.contextManager.makeCallTo(callee: numberToDial!.text!)
    }
    
    @objc
    func changeDialButtonTitleTo(_ title: String) {
        print("New (dial) button title: '\(title)'")
        btnDial?.setTitle(title, for: .normal)
        btnDial?.setTitle(title, for: .highlighted)
        btnDial?.setTitle(title, for: .selected)
        btnDial?.setTitle(title, for: .disabled)
    }
}

