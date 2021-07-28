//
//  LandingViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-24.
//

import UIKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        startWorkoutButton.setTitle("Start Workout", for: .normal)
        startWorkoutButton.layer.cornerRadius = 20
        prevWorkoutButton.setTitle("Previous Workouts", for: .normal)
        prevWorkoutButton.layer.cornerRadius = 20
        
        profileButton.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        profileButton.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        profileButton.tintColor = .systemOrange
        settingsButton.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        settingsButton.tintColor = .systemOrange
        
    }
    
    @IBOutlet weak var startWorkoutButton: UIButton!
    @IBOutlet weak var prevWorkoutButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBAction func didTapStartWorkout() {
        let vc = storyboard?.instantiateViewController(identifier: "Select") as! SelectWorkoutViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func didTapPrevWorkout() {
        let vc1 = storyboard?.instantiateViewController(identifier: "Previous") as! PreviousWorkoutsViewController
        vc1.modalPresentationStyle = .fullScreen
        present(vc1, animated: true)
    }
    
    @IBAction func didTapProfile() {
        let vc = storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func didTapSettings() {
        let vc = storyboard?.instantiateViewController(identifier: "Settings") as! SettingsViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}
