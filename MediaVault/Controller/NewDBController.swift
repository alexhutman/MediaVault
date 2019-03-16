//
//  NewDBController.swift
//  MediaVault
//
//  Created by alex on 2/28/18.
//  Copyright © 2018 alex. All rights reserved.
//

import Foundation
import UIKit
import SQLite
import CryptoSwift

protocol NewDBControllerDelegate {
    func receiveDBName(dbName: String)
}

class NewDBController: UIViewController, UITextFieldDelegate {
    let fileManager = FileManager.default
    var delegate: NewDBControllerDelegate?
    var userDBDir: URL!
    var userDB: Connection!
    let textTable = Table("text")
    let picsTable = Table("pictures")
    //let vidsTable = Table("videos")
    
    let mediaTitle = Expression<String>("title")
    let textData = Expression<String>("data")
    let mediaData = Expression<UIImage?>("data")
    let mediaDateModified = Expression<String>("modifiedOn")
    var dbNames = [String]()
    
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var dbNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBAction func doneButton(_ sender: Any) {
        var dbCreated = false
        var passwordsMatch = false
        var passHash = String()
        var confPassHash = String()
        let tryDBName = dbNameField.text!
        
        if tryDBName == "" {
            print("Empty DB Name field")
            presentAlert(title: "Error", message: "Please enter a name for your database")
            self.dbNameField.becomeFirstResponder()
        }
        
        //Create database
        do {
            //Create db/establish connection
            let fileUrl = userDBDir.appendingPathComponent(tryDBName).appendingPathExtension("db")
            print("path: \(fileUrl.path)")
            if self.fileManager.fileExists(atPath: fileUrl.path) {
                print("File exists already!")
                presentAlert(title: "Error", message: "Database \"\(tryDBName)\" already exists!")
                self.dbNameField.text = ""
                self.dbNameField.becomeFirstResponder()
            }
            if (passwordField.text == "" && passwordConfirmField.text == "") {
                print("Please enter a password to encrypt your database with!")
                presentAlert(title: "Error", message: "Please enter a password for your database")
            }
            else {
                
                passHash = (passwordField.text!).sha256()
                confPassHash = (passwordConfirmField.text!).sha256()
                if passHash == confPassHash {
                    passwordsMatch = true
                }
                else {
                    presentAlert(title: "Error", message: "Please make sure your passwords match")
                }
            }
            if !self.fileManager.fileExists(atPath: fileUrl.path) && passwordsMatch {
                print("File does not exist, creating \(tryDBName).db")
                let userDB = try Connection(fileUrl.path)
                try userDB.key(passHash)
                self.userDB = userDB
                
                //Create tables
                let createTextTable = self.textTable.create { (table) in
                    table.column(self.mediaTitle, primaryKey: true)
                    table.column(self.textData)
                    table.column(self.mediaDateModified)
                }
                let createPicsTable = self.picsTable.create { (table) in
                    table.column(self.mediaTitle, primaryKey: true)
                    table.column(self.mediaData)
                    table.column(self.mediaDateModified)
                }
                /*let createVidsTable = self.vidsTable.create { (table) in
                    table.column(self.mediaID, primaryKey: true)
                    //table.column(self.mediaName)
                    table.column(self.mediaData)
                    table.column(self.mediaDateAdded)
                }*/
                
                do {
                    try self.userDB.run(createTextTable)
                    try self.userDB.run(createPicsTable)
                    //try self.userDB.run(createVidsTable)
                    dbCreated = true
                } catch {
                    print(error)
                    dbCreated = false
                }
            }
        }
        catch {
            print(error)
        }
        
        //If create database is successful, pop view off stack (go back)
        if dbCreated && passwordsMatch{
            self.delegate?.receiveDBName(dbName: tryDBName)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor .black
        self.dbNameField.delegate = self
        self.passwordField.delegate = self
        self.passwordConfirmField.delegate = self
        do {
            let defaultDirectory = try self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let userDBDir = defaultDirectory.appendingPathComponent("userDBs")
            
            self.userDBDir = userDBDir
        }
        catch {
            print(error)
        }
        // Do any additional setup after loading the view, typically from a nib.
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
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doneButton(done)
        return true
    }
}
