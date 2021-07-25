import Foundation

struct user {
    var firstName: String
    var lastName: String
    var email: String
    var age: Int
    var height: Double
    var weight: Double
}

struct set {
    var reps: Int
    var avgVel: [Float]
    var peakVel: [Float]
}

struct exercise {
    var name: String
    var sets: Int
}

class UserData {
    static var personal: user = user(firstName: "John", lastName: "Doe", email: "jdoe@sfu.ca", age: 24, height: 183.0, weight: 200.0)
    
    //static var allw
}
