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
    var date: String
    var sets: [set]
}

struct set {
    var reps: Int
    var upVelData: [Float]
    var avgVel: [Float]
    var peakVel: [Float]
}

class UserData {
    
    static var personal: user = user(firstName: "John", lastName: "Doe", email: "jdoe@sfu.ca", age: 24, height: 183.0, weight: 200.0)
    
    static var workoutType: String = "None"
    
    static var tempUpAcc: [Float] = []
    
    static var tempUpVel: [Float] = []
    
    static var exer: exercise = exercise(type: "null", num_sets: 0, date: "", sets: [])
    
    static var past_exer: [exercise] = []
    
    static var whichCell: Int = 0
    
    static var whichSet: Int = 0
}
