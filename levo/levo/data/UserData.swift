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
    
    static var workouts: exercise = exercise(type: "Test", sets: [set(reps: 0, avgVel: [0], peakVel: [0])])
    
    static var tempUpVel: [Float] = [0.0]
    
    //static var allw
}
