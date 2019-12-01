//
//  HelpViewController.swift
//  MediaVault
//
//  Created by alex on 5/7/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit

class helpCell: UITableViewCell {
    @IBOutlet weak var helpOptionLabel: UILabel!
}

class HelpViewController: UITableViewController {
    let helpCellTitles = ["About", "Import/Export Database", "Recommend this app", "View my GitHub"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return helpCellTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helpCell", for: indexPath) as! helpCell

        cell.helpOptionLabel?.text = helpCellTitles[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: Other Rows
        if indexPath.row == 0 {
            performSegue(withIdentifier: "helpToAboutSegue", sender: self)
        }
        if indexPath.row == 1 {
            performSegue(withIdentifier: "helpToImportExportSegue", sender: self)
        }
        if indexPath.row == 2 {
            let activityVC = UIActivityViewController(activityItems: ["Download MediaVault from the App Store to encrypt text and images! <Link to future App Store page>"], applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                let popOver = activityVC.popoverPresentationController
                popOver?.sourceView = self.view
            }
            //navigationController?.popoverPresentationController?.sourceView = activityVC.view
            navigationController?.present(activityVC, animated: true, completion: nil)
        }
        if indexPath.row == helpCellTitles.count-1 {
            let webView = GitHubViewController()
            /*let webView = UIWebView()
            webView.frame = UIScreen.main.bounds
            webView.loadRequest(URLRequest(url: URL(string: "https://github.com/alexhutman")!))
            self.navigationItem.title = "GitHub" */
            self.navigationController?.pushViewController(webView, animated: true)
            //self.view.addSubview(webView)
        }
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
