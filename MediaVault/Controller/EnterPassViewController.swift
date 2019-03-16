//
//  EnterPassViewController.swift
//  MediaVault
//
//  Created by alex on 5/5/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit
import SQLite

class EnterPassViewController: UIViewController, UITextFieldDelegate {
    var catchDBName = String()
    var catchHashedPass = String()
    var userDBDir: URL!
    
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var dbNameLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func doneButton(_ sender: Any) {
        let hashedPass = (passwordField.text!).sha256()
        
        if (passwordField.text == "") {
            //TODO: ALERT to enter a password
            self.presentAlert(title: "Error", message: "Please enter a password")
        }
        else {
            do {
                let dbConn = try Connection(self.userDBDir.path)
                try dbConn.key(hashedPass)
                self.catchHashedPass = hashedPass
                performSegue(withIdentifier: "viewDBSegue", sender: self)
            } catch {
                presentAlert(title: "Error", message: "Password is incorrect")
            }
    }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor .black
        self.passwordField.delegate = self
        dbNameLabel.text = catchDBName + ".db"
        do {
            let userDBDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("userDBs").appendingPathComponent(catchDBName).appendingPathExtension("db")
            self.userDBDir = userDBDir
        } catch {
            presentAlert(title: "Error", message: "Database does not exist")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        let subview = alert.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.backgroundColor = UIColor .white
        alertContentView.tintColor = UIColor .black
        alertContentView.layer.cornerRadius = 15
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDBSegue" {
            let viewDBViewController = segue.destination as! ViewDBViewController
            viewDBViewController.catchDBName = self.catchDBName
            viewDBViewController.catchHashedPass = self.catchHashedPass
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doneButton(done)
        return true
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
