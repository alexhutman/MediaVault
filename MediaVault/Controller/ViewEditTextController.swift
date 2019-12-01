//
//  ViewEditTextController.swift
//  MediaVault
//
//  Created by alex on 5/7/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit
import SQLite

class ViewEditTextController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var showTextField: UITextView!
    
    
    var catchDBName = String()
    var catchFilename = String()
    var catchHashedPass = String()
    
    var openDB: Connection!
    let textTable = Table("text")
    let mediaTitle = Expression<String>("title")
    let textData = Expression<String>("data")
    let mediaDateModified = Expression<String>("modifiedOn")
    
    
    @IBAction func donePressed(_ sender: Any) {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        let curDate = formatter.string(from: currentDateTime)
        
        let file = self.textTable.filter(self.mediaTitle == self.catchFilename)
        let overwriteData = file.update(self.textData <- showTextField.text)
        let overwriteDate = file.update(self.mediaDateModified <- curDate)
        
        do {
            try self.openDB.run(overwriteData)
            try self.openDB.run(overwriteDate)
            self.navigationController?.popViewController(animated: true)
        } catch {
            //TODO: ALERT, couldnt overwrite file
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = catchFilename
        self.showTextField.delegate = self

        self.view.backgroundColor = UIColor .black
        do {
            let caughtDbURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userDBs").appendingPathComponent(catchDBName).appendingPathExtension("db")
            
            let openDB = try Connection(caughtDbURL.path)
            try openDB.key(catchHashedPass)
            self.openDB = openDB
        } catch {
            //TODO: Error, couldnt connect to db
        }
        
        do {
            let textFile = textTable.filter(mediaTitle == self.catchFilename)
            if let textFileSelected = try openDB.pluck(textFile) {
                self.showTextField.text! = textFileSelected[textData]
            } else {
                //TODO: ALERT ERROR
            }
        } catch {
            //TODO: ALERT, couldnt find file in database
        }
            
            //TODO: Do this in viewDidAppear() maybe? Idk, copy what you did for HomePage           EDIT: Dont think this is necessary
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
