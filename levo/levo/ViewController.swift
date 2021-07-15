
//  ViewController.swift
//  levo
//
//  Created by Antonio Kim on 2021-06-21.
//
import UIKit

class ViewController: UIViewController {
    
    var xAcc: [Float] = [3.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(catchNoti(_:)), name: Notification.Name("array"), object: nil)
        arr_label.text = "No Data"
        btn.setTitle("Start", for: .normal)
    }
    
    @objc func catchNoti(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        xAcc = arr ?? [2.0]
        print("catch!")
        arr_label.text = "\(xAcc[0])"
    }
    
    @IBOutlet weak var arr_label: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    @IBAction func didtap() {
        let vc = storyboard?.instantiateViewController(identifier: "Results") as! ResultsViewController
        present(vc, animated: true)
    }
}
