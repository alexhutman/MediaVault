//
//  HomePageViewController.swift
//  MediaVault
//
//  Created by alex on 2/28/18.
//  Copyright © 2018 alex. All rights reserved.
//

import Foundation
import UIKit
import SQLite

class dbTableViewCell: UITableViewCell {
    @IBOutlet weak var dbNameLabel: UILabel!
    @IBOutlet weak var dbMetadataLabel: UILabel!
    @IBOutlet weak var dbLocLabel: UILabel!
    
    @IBOutlet weak var cellView: UIView!
}

//TODO: Make edit button so you can rename the db?

class HomePageViewController: UITableViewController, NewDBControllerDelegate {
    var isRenameSelected = false
    @IBAction func renamePressed(_ sender: Any) {
        tableView.reloadData()
        if isRenameSelected{
            isRenameSelected = false
        }
        else {
            isRenameSelected = true
        }
    }
    
    let fileManager = FileManager.default
    var metadataDbURL: URL!
    var metadataDB: Connection!
    let metadataTable = Table("metadata")
    let metadataID = Expression<String>("id")
    let metadataLastTime = Expression<String>("lastTime")
    let metadataLastLoc = Expression<String>("lastLoc")
    
    var dbNamesArr = [String]()
    var dbLastLoginArr = [String]()
    var dbLastLocArr = [String]()
    
    var userDbDir: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.toolbar.barTintColor = UIColor .black
        self.navigationController?.toolbar.tintColor = UIColor .white
        // Do any additional setup after loading the view, typically from a nib.
        do {
            let defaultDir = try self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            self.metadataDbURL = defaultDir.appendingPathComponent("metadata").appendingPathExtension("db")
            
            //Create /userDBs if needed, set it as userDbDir
            let userDbDir = defaultDir.appendingPathComponent("userDBs")
            try fileManager.createDirectory(atPath: userDbDir.path, withIntermediateDirectories: true, attributes: nil)
            self.userDbDir = userDbDir
            
            
            if !self.fileManager.fileExists(atPath: self.metadataDbURL.path) {
                let metadataDB = try Connection(self.metadataDbURL.path)
                self.metadataDB = metadataDB
                
                //Create table
                let createTable = self.metadataTable.create { (table) in
                    table.column(self.metadataID, primaryKey: true)
                    //table.column(self.mediaName)
                    table.column(self.metadataLastTime)
                    table.column(self.metadataLastLoc)
                }
                
                try self.metadataDB.run(createTable)
            }
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.dataSource = self
        tableView.delegate = self
        print("The view appeared!")
        do {
            var dbNamesArr = [String]()
            var dbLastLoginArr = [String]()
            var dbLastLocArr = [String]()
            
            let metadataDB = try Connection(self.metadataDbURL.path)
            self.metadataDB = metadataDB
            print("Connected to metadata.db")
            
            let databases = try self.metadataDB.prepare(self.metadataTable)
            for db in databases {
                dbNamesArr.append(db[self.metadataID])
                dbLastLoginArr.append(db[self.metadataLastTime])
                dbLastLocArr.append(db[self.metadataLastLoc])
            }
            self.dbNamesArr = dbNamesArr
            self.dbLastLoginArr = dbLastLoginArr
            self.dbLastLocArr = dbLastLocArr
            
            tableView.reloadData()
            
            //print("DBNAMESARR: \(self.dbNamesArr)")
            //print("DBLASTLOGINARR: \(self.dbLastLoginArr)")  //These print the correct results
        } catch {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //@IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
      //  let newDbVC = sender.source as? NewDBController
      //  dbNames.append((newDbVC?.dbNameField.text)!)
   // }
    
    func handleOpenURL() {
        do {
            var dbNamesArr = [String]()
            var dbLastLoginArr = [String]()
            var dbLastLocArr = [String]()
            
            let metadataDB = try Connection(self.metadataDbURL.path)
            self.metadataDB = metadataDB
            print("Connected to metadata.db")
            
            let databases = try self.metadataDB.prepare(self.metadataTable)
            for db in databases {
                dbNamesArr.append(db[self.metadataID])
                dbLastLoginArr.append(db[self.metadataLastTime])
                dbLastLocArr.append(db[self.metadataLastLoc])
            }
            self.dbNamesArr = dbNamesArr
            self.dbLastLoginArr = dbLastLoginArr
            self.dbLastLocArr = dbLastLocArr
            
            tableView.reloadData()
            
            //print("DBNAMESARR: \(self.dbNamesArr)")
            //print("DBLASTLOGINARR: \(self.dbLastLoginArr)")  //These print the correct results
        } catch {
            print(error)
        }
    }
    
    func receiveDBName(dbName: String) {
        let dbName = dbName
        print("Received \(dbName). Now trying to insert <\(dbName)> into metadata.db")
        let insertDBNameToMetadataDB = self.metadataTable.insert(self.metadataID <- dbName, self.metadataLastLoc <- "-", self.metadataLastTime <- "-")
        do {
            let metadataDB = try Connection(self.metadataDbURL.path)
            self.metadataDB = metadataDB
            try self.metadataDB.run(insertDBNameToMetadataDB)
            print("Inserted <\(dbName)> into metadata.db")
        } catch {
            print(error)
        }
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print("NUMROWS: \(self.dbNamesArr.count)")
        return self.dbNamesArr.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isRenameSelected {
            let alert = UIAlertController(title: "What would you like to rename \(self.dbNamesArr[indexPath.row]) to?", message: nil, preferredStyle: .alert)
            alert.addTextField { (tf) in tf.placeholder = "Title"}
            let action = UIAlertAction(title: "Ok", style: .default) { (_) in
                guard let title = alert.textFields?.first?.text
                    else{return}
                if title == "" {
                    let alert = UIAlertController(title: "Error", message: "Please enter a file name", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.navigationController?.present(alert, animated: true, completion: nil)
                }
                else {
                    do {
                        let selectedDB = self.metadataTable.filter(self.metadataID == self.dbNamesArr[indexPath.row])
                        let updateName = selectedDB.update(self.metadataID <- title)
                        try self.metadataDB.run(updateName)
                        
                        let curDBLoc = self.userDbDir.appendingPathComponent(self.dbNamesArr[indexPath.row]).appendingPathExtension("db")
                        let renamedDBLoc = self.userDbDir.appendingPathComponent(title).appendingPathExtension("db")
                        try self.fileManager.moveItem(at: curDBLoc, to: renamedDBLoc)
                        
                        let databases = try self.metadataDB.prepare(self.metadataTable)
                        
                        var dbNamesArr = [String]()
                        var dbLastLoginArr = [String]()
                        var dbLastLocArr = [String]()
                        
                        for db in databases {
                            dbNamesArr.append(db[self.metadataID])
                            dbLastLoginArr.append(db[self.metadataLastTime])
                            dbLastLocArr.append(db[self.metadataLastLoc])
                        }
                        self.dbNamesArr = dbNamesArr
                        self.dbLastLoginArr = dbLastLoginArr
                        self.dbLastLocArr = dbLastLocArr
                        
                        self.tableView.reloadData()
                    } catch {
                        let alert = UIAlertController(title: "Error", message: "Filename already exists", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self.navigationController?.present(alert, animated: true, completion: nil)
                    }
                
                }
                
            }
            alert.addAction(action)
            navigationController?.present(alert, animated: true, completion: nil)
            self.isRenameSelected = false
        }
        else {
            performSegue(withIdentifier: "enterPasswordSegue", sender: self)
        }
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dbCellID", for: indexPath) as! dbTableViewCell
        //cell.selectionStyle = .none
     // Configure the cell...
        //print("DBNAMESARR: \(self.dbNamesArr)")
        //print("DBLASTLOGINARR: \(self.dbLastLoginArr)") //These do not print anything, not even "DBNAMESARR: "
        cell.accessoryType = .disclosureIndicator
        cell.dbNameLabel?.text = self.dbNamesArr[indexPath.row] + ".db"
        cell.dbMetadataLabel?.text = "Last opened on " + self.dbLastLoginArr[indexPath.row]
        cell.dbLocLabel?.text = "from " + self.dbLastLocArr[indexPath.row]
        var bgColor: UIColor
        var txtColor: UIColor
        if isRenameSelected {
            bgColor = UIColor.lightGray
            txtColor = UIColor.white
        } else {
            bgColor = UIColor.white
            txtColor = UIColor.darkGray
        }
        
        cell.dbMetadataLabel.textColor = txtColor
        cell.dbLocLabel.textColor = txtColor
        cell.backgroundColor = bgColor
        cell.cellView.backgroundColor = bgColor
        
     return cell
     }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        let dbName = dbNamesArr[indexPath.row]
        
        let dbPath = self.userDbDir.appendingPathComponent(dbName).appendingPathExtension("db")
        let dbToDelete = self.metadataTable.filter(self.metadataID == dbName)
        let deleteDb = dbToDelete.delete()
        do {
            try fileManager.removeItem(at: dbPath)
            try self.metadataDB.run(deleteDb)
        } catch {
            print(error)
        }
        dbNamesArr.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneDBSegue" {
            let newDBController = segue.destination as! NewDBController
            newDBController.delegate = self
        }
        if segue.identifier == "enterPasswordSegue" {
            let indexPath = tableView.indexPathForSelectedRow
            let enterPassViewController = segue.destination as! EnterPassViewController
            
            let selectedDB = dbNamesArr[indexPath!.row]
            
            enterPassViewController.catchDBName = selectedDB
        }
    }
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
    
}
