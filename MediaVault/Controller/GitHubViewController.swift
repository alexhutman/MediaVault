//
//  GitHubViewController.swift
//  MediaVault
//
//  Created by alex on 5/9/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit

class GitHubViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = UIWebView()
        webView.frame = UIScreen.main.bounds
        webView.loadRequest(URLRequest(url: URL(string: "https://github.com/alexhutman")!))
        self.navigationItem.title = "GitHub"
        self.view.addSubview(webView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
