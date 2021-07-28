import Foundation

struct user {
    var firstName: String
    var lastName: String
    var email: String
    var age: Int
    var height: Double
    var weight: Double
}

struct exercise {
    var type: String
    var num_sets: Int
    var sets: [set]
}

struct set {
    var reps: Int
    var avgVel: [Float]
    var peakVel: [Float]
}

class UserData {
    
    static var workoutType: String = "None"
    
    static var personal: user = user(firstName: "John", lastName: "Doe", email: "jdoe@sfu.ca", age: 24, height: 183.0, weight: 200.0)
    
    static var exer: exercise = exercise(type: "null", num_sets: 0, sets: [])
    
    static var past_exer: [exercise] = [
        exercise(type: "Bench Press", num_sets: 2, sets: [
                set(reps: 0, avgVel: [0.0], peakVel: [0.0]),
                set(reps: 0, avgVel: [0.0], peakVel: [0.0])
                ]),
        exercise(type: "Deadlift", num_sets: 2, sets: [
                set(reps: 0, avgVel: [0.0], peakVel: [0.0]),
                set(reps: 0, avgVel: [0.0], peakVel: [0.0])
                ]),
        exercise(type: "Squat", num_sets: 3, sets: [
                set(reps: 0, avgVel: [0.0], peakVel: [0.0]),
                set(reps: 0, avgVel: [0.0], peakVel: [0.0]),
                set(reps: 0, avgVel: [0.0], peakVel: [0.0])
                ]),
        exercise(type: "Clean", num_sets: 3, sets: [
                set(reps: 0, avgVel: [0.0], peakVel: [0.0]),
                set(reps: 0, avgVel: [0.0], peakVel: [0.0]),
                set(reps: 0, avgVel: [0.0], peakVel: [0.0])
                ]),
    ]
    
    static var tempUpVel: [Float] = [0.0]
    
    static var whichCell: Int = 0
    
    static var whichSet: Int = 0
}
