//
//  PreviousWorkoutsViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-26.
//

import UIKit

class PreviousWorkoutsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        testLbl.text = "\(UserData.past_exer[0].type)"
        testLbl1.text = "\(UserData.past_exer[1].type)"

    }
    
    @IBOutlet weak var testLbl: UILabel!
    
    @IBOutlet weak var testLbl1: UILabel!

}
