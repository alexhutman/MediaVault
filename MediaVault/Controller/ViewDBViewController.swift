//
//  ViewDBViewController.swift
//  MediaVault
//
//  Created by alex on 5/5/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit
import SQLite
import CoreLocation
import MobileCoreServices

class viewDBDataCell: UITableViewCell {
    @IBOutlet weak var dataNameLabel: UILabel!
    
    @IBOutlet weak var dateInfo: UILabel!
    @IBOutlet weak var dataTimeAddedLabel: UILabel!
}

class ViewDBViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIDocumentInteractionControllerDelegate{
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    
    /*
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return self.dbData
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        return self.dbData
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "\(self.catchDBName).db"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivityType?) -> String {
        return "com.torsion.MediaVault.document.db"
    }
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return #imageLiteral(resourceName: "databaseIcon.png")
    }
    */
    //Icons made by Smashicons (https://www.flaticon.com/authors/smashicons) from https://www.flaticon.com/ Flaticon is licensed by Creative Commons BY 3.0 (http://creativecommons.org/licenses/by/3.0/)
    let formatter = DateFormatter()
    var locationManager: CLLocationManager! //TODO: THIS
    lazy var geocoder = CLGeocoder()
    let imgPicker = UIImagePickerController()
    
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var catchDBName = String()
    var catchHashedPass = String()
    var fileNameToPass = String()
    
    let sectionTitles: [String] = ["Text Files", "Images"]
    let sectionImages: [UIImage] = [#imageLiteral(resourceName: "textIcon"), #imageLiteral(resourceName: "pictureIcon")]
    var textFileNames = [String]()
    var textFileDatesModified = [String]()
    var imagesNames = [String]()
    var imageDatesModified = [String]()
    
    let picsTable = Table("pictures")
    let picTitle = Expression<String>("title")
    let picData = Expression<UIImage?>("data")
    let picDateModified = Expression<String>("modifiedOn")
    
    let fileManager = FileManager.default
    var caughtDbURL: URL!
    var docController: UIDocumentInteractionController!
    
    @IBAction func sharePressed(_ sender: Any) {
        docController.presentPreview(animated: true)
           docController.presentOptionsMenu(from: shareButton, animated: true)
        
        print("FILE LOC: \(self.caughtDbURL.path)")
    }
    @IBAction func addMedia(_ sender: Any) {
        let sheet = UIAlertController(title: "What would you like to add?", message: nil, preferredStyle: .actionSheet)
        
        let addText = UIAlertAction(title: "Text", style: .default) { (action) in
            self.performSegue(withIdentifier: "addTextSegue", sender: self)
            //TODO: Segue to AddText view
        }
        let addPic = UIAlertAction(title: "Picture", style: .default) { (action) in
            self.imgPicker.allowsEditing = false
            self.imgPicker.sourceType = .photoLibrary
            self.present(self.imgPicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
            //TODO: Don't make another view, just bring up image picker
        }
        /*let addVideo = UIAlertAction(title: "Video", style: .default) { (action) in  //MIGHT BE ABLE TO COMBINE PIC/VID
            print("Video selected")
            let videoPicker = UIImagePickerController()
            videoPicker.delegate = self
            videoPicker.mediaTypes = [kUTTypeMovie as String]
            videoPicker.allowsEditing = true
            videoPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(videoPicker, animated: true, completion: nil)
        } */

        
        sheet.addAction(addText)
        sheet.addAction(addPic)
        sheet.addAction(cancel)
        sheet.popoverPresentationController?.sourceView = self.view
        //sheet.addAction(addVideo)
        
        present(sheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let alert = UIAlertController(title: "What would you like to name this picture?", message: nil, preferredStyle: .alert)
            alert.addTextField { (tf) in tf.placeholder = "Title"}
            let action = UIAlertAction(title: "Ok", style: .default) { (_) in
                guard let title = alert.textFields?.first?.text
                    else{return}
                if title == "" {
                    let alert = UIAlertController(title: "Error", message: "Please enter a file name", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.topMostController().present(alert, animated: true, completion: nil)
                }
                else {
                do {
                    let currentDateTime = Date()
                    let curDate = self.formatter.string(from: currentDateTime)
                    let caughtDB = try Connection(self.caughtDbURL.path)
                    try caughtDB.key(self.catchHashedPass)
                    let insertPic = self.picsTable.insert(self.picTitle <- title, self.picData <- chosenImage, self.picDateModified <- curDate)
                    
                    try caughtDB.run(insertPic)
                } catch {
                    let alert = UIAlertController(title: "Error", message: "Filename already exists", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.topMostController().present(alert, animated: true, completion: nil)
                }
                
                picker.dismiss(animated: true, completion: nil)
                }
    
            }
            alert.addAction(action)
            self.topMostController().present(alert, animated: true) { () in
                print("Presented filename alert")
            }
            //picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func topMostController() -> UIViewController {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while ((topViewController?.presentedViewController) != nil) {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "\(catchDBName).db"
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        checkCoreLocationPermission()
    }
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        do {
            var textFileNames = [String]()
            var textFileDatesModified = [String]()
            var imagesNames = [String]()
            var imageDatesModified = [String]()
            
            let openDB = try Connection(self.caughtDbURL.path)
            try openDB.key(catchHashedPass)
            
            let textTable = Table("text")
            let picsTable = Table("pictures")
            
            let mediaTitle = Expression<String>("title")
            let mediaDateModified = Expression<String>("modifiedOn")
            
            let text = try openDB.prepare(textTable)
            for textEntry in text {
                textFileNames.append(textEntry[mediaTitle])
                textFileDatesModified.append(textEntry[mediaDateModified])
            }
            
            let pics = try openDB.prepare(picsTable)
            for picEntry in pics {
                imagesNames.append(picEntry[mediaTitle])
                imageDatesModified.append(picEntry[mediaDateModified])
            }
            self.textFileNames = textFileNames
            self.textFileDatesModified = textFileDatesModified
            self.imagesNames = imagesNames
            self.imageDatesModified = imageDatesModified
            
            tableView.reloadData()
            
            //print("DBNAMESARR: \(self.dbNamesArr)")
            //print("DBLASTLOGINARR: \(self.dbLastLoginArr)")  //These print the correct results
            
            
            //self.tableView.reloadData() //breaks everything
            
            //TODO: POSSIBLY TWEAK THIS TO GET DATA TO RELOAD?
            //dispatch_async(dispatch_get_main_queue()) {
            //    self.reminderTableView.reloadData()
            //}
        } catch {
            print(error)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formatter.timeStyle = .medium
        self.formatter.dateStyle = .medium
        imgPicker.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        do {
            let defaultDir = try self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let caughtDbURL = defaultDir.appendingPathComponent("userDBs").appendingPathComponent(catchDBName).appendingPathExtension("db")
            self.caughtDbURL = caughtDbURL
            docController = UIDocumentInteractionController(url: caughtDbURL)
            docController.delegate = self
            //TODO: Do this in viewDidAppear() maybe? Idk, copy what you did for HomePage

        } catch {
            print(error) //TODO: Alert?
        }
        //TODO: Figure out how to segue directly to HomePageViewController, skip Password page
        //TODO: Log into db, get current time date, parse it, then pass it back to HomePageViewController
        
        print("Caught DB with name: \(catchDBName)")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            print("Not authorized to use location. Using \"-\" as location.")
            let alert = UIAlertController(title: "Error", message: "Enable location services to see last location this database was opened from", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let location = locations.last as! CLLocation
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
            })
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Unable to find location", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print(error)
            let alert = UIAlertController(title: "Error", message: "Unable to find location", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                let locationString = placemark.locality! + ", " + placemark.administrativeArea!
                let currentDateTime = Date()
                let curDateStr = self.formatter.string(from: currentDateTime)
                do {
                    let defaultDir = try self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    let metadataDbURL = defaultDir.appendingPathComponent("metadata").appendingPathExtension("db")
                    let metadataTable = Table("metadata")
                    let metadataID = Expression<String>("id")
                    let metadataLastTime = Expression<String>("lastTime")
                    let metadataLastLoc = Expression<String>("lastLoc")
                    let metadataDB = try Connection(metadataDbURL.path)
                    
                    let metadataDbEntry = metadataTable.filter(metadataID == catchDBName)
                    let updateTime = metadataDbEntry.update(metadataLastTime <- curDateStr)
                    print("LOCATION STRING (before insert): " + locationString)
                    let updateLoc = metadataDbEntry.update(metadataLastLoc <- locationString)
                    
                    try metadataDB.run(updateTime)
                    try metadataDB.run(updateLoc)
                } catch {
                    let alert = UIAlertController(title: "Error", message: "Unable to find location", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            
            } else {
                let alert = UIAlertController(title: "Error", message: "Unable to find location", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return textFileNames.count
        }
        else {
            return imagesNames.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewDBCellID", for: indexPath) as! viewDBDataCell

        // Configure the cell...
        if indexPath.section == 0 {
            cell.dataNameLabel.text = textFileNames[indexPath.row]
            cell.dateInfo.text = "Date modified:"
            cell.dataTimeAddedLabel.text = textFileDatesModified[indexPath.row]
        }
        else {
            cell.dataNameLabel.text = imagesNames[indexPath.row]
            cell.dateInfo.text = "Date added:"
            cell.dataTimeAddedLabel.text = imageDatesModified[indexPath.row]
        }

        return cell
    } //TODO: SOMETHING DIFFERENT FOR TEXT/IMAGES
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    //override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
    //    return sectionTitles[section]
    //}
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor .black
        
        let image = UIImageView(image: sectionImages[section])
        image.frame = CGRect(x: 5, y: 5, width: 35, height: 35)
        view.addSubview(image)
        
        let label = UILabel()
        label.text = sectionTitles[section]
        label.textColor = UIColor .white
        label.frame = CGRect(x: 45, y: 5, width: 100, height: 35)
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTextSegue" {
            let addTextVC = segue.destination as! AddTextViewController
            addTextVC.catchDBName = self.catchDBName
            addTextVC.catchHashedPass = self.catchHashedPass
        }
        if segue.identifier == "viewEditTextSegue" {
            let viewTextVC = segue.destination as! ViewEditTextController
            viewTextVC.catchDBName = self.catchDBName
            viewTextVC.catchFilename = self.fileNameToPass
            viewTextVC.catchHashedPass = self.catchHashedPass
        }
        if segue.identifier == "viewImageSegue" {
            let viewImageVC = segue.destination as! ViewImageController
            var picture = UIImage()
            do {
                let caughtDbURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userDBs").appendingPathComponent(catchDBName).appendingPathExtension("db")
                
                let openDB = try Connection(caughtDbURL.path)
                try openDB.key(catchHashedPass)
                let imgFile = self.picsTable.filter(self.picTitle == self.fileNameToPass)
                if let picSelected = try openDB.pluck(imgFile) {
                    picture = picSelected[self.picData]!
                }
                //TODO: Error, couldnt connect to db
                } catch {
                    
                }

            viewImageVC.caughtImage = picture
            viewImageVC.catchFilename = self.fileNameToPass
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.fileNameToPass = textFileNames[indexPath.row]
            performSegue(withIdentifier: "viewEditTextSegue", sender: self)
        }
        else {
            self.fileNameToPass = imagesNames[indexPath.row] //HFEIHFUEHIUFWEHFEIWUHFWEIUHEFIUFHWIUEHFIUHWEIFHIUWEHFIWEHIUWEHFIUEH
            performSegue(withIdentifier: "viewImageSegue", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        if indexPath.section == 0 {
            let curName = textFileNames[indexPath.row]
            let textToDelete = Table("text").filter(Expression<String>("title") == curName)
            let deleteTxtFile = textToDelete.delete()
            do {
                let caughtDB = try Connection(self.caughtDbURL.path)
                try caughtDB.key(self.catchHashedPass)
                try caughtDB.run(deleteTxtFile)
                textFileNames.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                presentAlert(title: "Error", message: "Could not delete file")
                
            }
        }
        else {
            let curName = imagesNames[indexPath.row]
            let imgToDelete = self.picsTable.filter(self.picTitle == curName)
            let deletePic = imgToDelete.delete()
            do {
                let caughtDB = try Connection(self.caughtDbURL.path)
                try caughtDB.key(self.catchHashedPass)
                try caughtDB.run(deletePic)
                imagesNames.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                presentAlert(title: "Error", message: "Could not delete file")
                
            }
        }

        //tableView.deleteRows(at: [indexPath], with: .automatic)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
