//
//  ViewImageController.swift
//  MediaVault
//
//  Created by alex on 5/7/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit
import SQLite

class ViewImageController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewer: UIImageView!
    var caughtImage: UIImage!
    
    @IBAction func sharePressed(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [UIImageJPEGRepresentation(self.caughtImage, 1)], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = imageViewer
        activityVC.view.layoutIfNeeded()
        activityVC.view.snapshotView(afterScreenUpdates: true)
        
        DispatchQueue.main.async {
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    var catchFilename = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor .black
        self.title = catchFilename
        
        self.view.snapshotView(afterScreenUpdates: true)
        
        self.scrollView.maximumZoomScale = 5.0
        self.scrollView.clipsToBounds = true
        
        self.imageViewer.image = self.caughtImage
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageViewer
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
