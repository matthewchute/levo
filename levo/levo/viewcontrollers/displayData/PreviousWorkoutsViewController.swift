//
//  PreviousWorkoutsViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-26.
//

import UIKit

class PreviousWorkoutsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserData.past_exer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = UserData.past_exer[indexPath.row].type.description
        
        cell.detailTextLabel?.text = UserData.past_exer[indexPath.row].date.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UserData.whichCell = indexPath.row
        let vc = storyboard?.instantiateViewController(identifier: "Sets") as! SetDisplayViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLbl.text = "Exercise History"
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
