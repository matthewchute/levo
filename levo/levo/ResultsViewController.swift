//
//  ResultsViewController.swift
//  levo
//
//  Created by Antonio Kim on 2021-07-12.
//

import UIKit
import SwiftUI

//let otherVc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
//var xAcc: [Float] = otherVc?.xAcc ?? [0.0]
let Vc = ViewController(nibName: "ViewController", bundle: nil)
var xAcc: [Float] = Vc.xAcc 

class ResultsViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBSegueAction func view_graph(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: ActivityGraph(logs: xAcc, selectedIndex: .constant(3)))
        
    }
}
