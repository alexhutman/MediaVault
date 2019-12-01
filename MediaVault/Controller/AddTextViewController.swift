//
//  AddTextViewController.swift
//  MediaVault
//
//  Created by alex on 5/6/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit
import SQLite

class AddTextViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var textFileName: UITextField!
    @IBOutlet weak var fileContentField: UITextView!
    
    var userDB: Connection!
    let textTable = Table("text")
    let textTitle = Expression<String>("title")
    let textData = Expression<String>("data")
    let textDateModified = Expression<String>("modifiedOn")
    
    var catchDBName = String()
    var catchHashedPass = String()
    @IBAction func doneButton(_ sender: Any) {
        if textFileName.text == "" {
            presentAlert(title: "Error", message: "Please enter a file name")
        }
        else {
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .medium
            let curDate = formatter.string(from: currentDateTime)
            
            let insertText = textTable.insert(textTitle <- textFileName.text!, textData <- fileContentField.text!, textDateModified <- curDate)
            do {
                try self.userDB.run(insertText)
                self.navigationController?.popViewController(animated: true)
            } catch {
                presentAlert(title: "Error", message: "File name already exists")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor .black
        
        self.textFileName.delegate = self
        self.fileContentField.delegate = self
        self.fileContentField.returnKeyType = .done
        
        do {
            let userDBDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("userDBs").appendingPathComponent(self.catchDBName).appendingPathExtension("db")
            
                let dbConn = try Connection(userDBDir.path)
                try dbConn.key(catchHashedPass)
                self.userDB = dbConn
        } catch {
            presentAlert(title: "Error", message: "Error connecting to database")
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doneButton(done)
        return true
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
