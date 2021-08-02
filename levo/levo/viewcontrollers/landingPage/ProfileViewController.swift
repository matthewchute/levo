//
//  ProfileViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-24.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(catchPersonal(_:)), name: Notification.Name("personal"), object: nil)
        
        titleLbl.text = "Profile"
        
        editBtn.setTitle("Edit", for: .normal)
        editBtn.layer.cornerRadius = 20
        
        firstName.attributedText = makeFont2("First Name: ", UserData.personal.firstName)
        lastName.attributedText = makeFont2("Last Name: ", UserData.personal.lastName)
        email.attributedText = makeFont2("Email: ", UserData.personal.email)
        age.attributedText = makeFont2("Age: ", String(UserData.personal.age))
        height.attributedText = makeFont3("Height: ", String(UserData.personal.height), " cm")
        weight.attributedText = makeFont3("Weight: ", String(UserData.personal.weight), " lbs")

        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange
        
    }
    
    @objc func catchPersonal(_ noti: Notification) {
        if let (_, _, _, _, _, _) = noti.object as! (String, String, String, Int, Double, Double)? {
            firstName.attributedText = makeFont2("First Name: ", UserData.personal.firstName)
            lastName.attributedText = makeFont2("Last Name: ", UserData.personal.lastName)
            email.attributedText = makeFont2("Email: ", UserData.personal.email)
            age.attributedText = makeFont2("Age: ", String(UserData.personal.age))
            height.attributedText = makeFont3("Height: ", String(UserData.personal.height), " cm")
            weight.attributedText = makeFont3("Weight: ", String(UserData.personal.weight), " lbs")
        }
    }
    
    func makeFont2(_ firstPart: String, _ secondPart: String) -> NSMutableAttributedString {
        let bold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .bold)]
        let regular = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .regular)]
        let str = NSMutableAttributedString(string: firstPart, attributes: bold)
        let secondStr = NSMutableAttributedString(string: secondPart, attributes: regular)
        str.append(secondStr)
        return str
    }
    
    func makeFont3(_ firstPart: String, _ secondPart: String, _ thirdPart: String) -> NSMutableAttributedString {
        let bold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .bold)]
        let regular = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .regular)]
        let str = NSMutableAttributedString(string: firstPart, attributes: bold)
        let secondStr = NSMutableAttributedString(string: secondPart, attributes: regular)
        let thirdStr = NSMutableAttributedString(string: thirdPart, attributes: regular)
        str.append(secondStr)
        str.append(thirdStr)
        return str
    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    
    @IBAction func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapEdit() {
        let vc = storyboard?.instantiateViewController(identifier: "EditProfile") as! EditProfileViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    

}
