//
//  AboutPageViewController.swift
//  MediaVault
//
//  Created by alex on 5/9/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit

class AboutPageViewController: UIViewController {
    @IBOutlet weak var aboutTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor .black
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.aboutTextView.setContentOffset(CGPoint.zero, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
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
