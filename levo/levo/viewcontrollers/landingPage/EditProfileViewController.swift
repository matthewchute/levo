//
//  EditProfileViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-08-02.
//

import UIKit

class EditProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.layer.cornerRadius = 20
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.layer.cornerRadius = 20
        titleLbl.text = "Edit Profile"
        firstNameLbl.text = "First Name: "
        lastNameLbl.text = "Last Name: "
        emailLbl.text = "Email: "
        ageLbl.text = "Age: "
        heightLbl.text = "Height: "
        weightLbl.text = "Weight: "
        
        firstNameTF.text = UserData.personal.firstName
        lastNameTF.text = UserData.personal.lastName
        emailTF.text = UserData.personal.email
        ageTF.text = String(UserData.personal.age)
        heightTF.text = String(UserData.personal.height)
        weightTF.text = String(UserData.personal.weight)

    }
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    
    
    @IBAction func tapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapSave() {
        UserData.personal.firstName = firstNameTF.text ?? UserData.personal.firstName
        UserData.personal.lastName = lastNameTF.text ?? UserData.personal.lastName
        UserData.personal.email = emailTF.text ?? UserData.personal.lastName
        UserData.personal.age = Int(ageTF.text!) ?? UserData.personal.age
        UserData.personal.height = Double(heightTF.text!) ?? UserData.personal.height
        UserData.personal.weight = Double(weightTF.text!) ?? UserData.personal.weight
        NotificationCenter.default.post(name: Notification.Name("personal"), object: (UserData.personal.firstName, UserData.personal.lastName, UserData.personal.email, UserData.personal.age, UserData.personal.height, UserData.personal.weight))
        dismiss(animated: true, completion: nil)
    }

}
