//
//  SettingsViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-24.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLbl.text = "Settings"

        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange
        
    }
    

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBAction func goBack() {
        dismiss(animated: true, completion: nil)
    }

}
