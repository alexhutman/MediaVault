//
//  SettingsController.swift
//  MediaVault
//
//  Created by Hutman, Alexander L. on 4/25/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let timeoutOptions = ["0:30", "1:00", "1:30"]
    
    @IBOutlet weak var clearClipboardSwitch: UISwitch!
    @IBOutlet weak var timeoutPicker: UIPickerView!
    @IBOutlet weak var timeoutButton: UIButton!
    @IBAction func selectTimeoutPressed(_ sender: UIButton) {
        if timeoutPicker.isHidden {
            timeoutPicker.isHidden = false
        }
    }
    @IBAction func clearClipboard(_ sender: Any) {
        if clearClipboardSwitch.isOn {
            timeoutButton.isEnabled = true
            timeoutButton.isHidden = false
        }
        else {
            timeoutButton.isEnabled = false
            timeoutButton.isHidden = true
            timeoutPicker.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor .black
        self.clearClipboardSwitch.onTintColor = UIColor .lightGray
        self.timeoutPicker.tintColor = UIColor .white
        timeoutButton.isEnabled = false
        timeoutButton.isHidden = true
        
        timeoutPicker.isHidden = true
        
        timeoutPicker.delegate = self
        timeoutPicker.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeoutOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        return NSAttributedString(string: timeoutOptions[row], attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeoutButton.setTitle(timeoutOptions[row], for: .normal)
        timeoutPicker.isHidden = true
    }
    
}


