//
//  SelectWorkoutViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-26.
//

import UIKit

class SelectWorkoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        benchBtn.setTitle("Bench Press", for: .normal)
        benchBtn.layer.cornerRadius = 20
        deadliftBtn.setTitle("Deadlift", for: .normal)
        deadliftBtn.layer.cornerRadius = 20
        squatBtn.setTitle("Squat", for: .normal)
        squatBtn.layer.cornerRadius = 20
        cleanBtn.setTitle("Clean", for: .normal)
        cleanBtn.layer.cornerRadius = 20
        
        titleLbl.text = "Workouts"
        
        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var benchBtn: UIButton!
    @IBOutlet weak var deadliftBtn: UIButton!
    @IBOutlet weak var squatBtn: UIButton!
    @IBOutlet weak var cleanBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBAction func didTapBackBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapBenchBtn() {
        let vc = storyboard?.instantiateViewController(identifier: "Workout") as! WorkoutViewController
        vc.modalPresentationStyle = .fullScreen
        UserData.workoutType = "Bench Press"
        present(vc, animated: true)
    }
    
    @IBAction func didTapDeadBtn() {
        let vc = storyboard?.instantiateViewController(identifier: "Workout") as! WorkoutViewController
        vc.modalPresentationStyle = .fullScreen
        UserData.workoutType = "Deadlift"
        present(vc, animated: true)
    }
    
    @IBAction func didTapSquatBtn() {
        let vc = storyboard?.instantiateViewController(identifier: "Workout") as! WorkoutViewController
        vc.modalPresentationStyle = .fullScreen
        UserData.workoutType = "Squat"
        present(vc, animated: true)
    }
    
    @IBAction func didTapClearBtn() {
        let vc = storyboard?.instantiateViewController(identifier: "Workout") as! WorkoutViewController
        vc.modalPresentationStyle = .fullScreen
        UserData.workoutType = "Clean"
        present(vc, animated: true)
    }
    

}
