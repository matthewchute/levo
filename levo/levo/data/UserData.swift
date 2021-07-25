import Foundation

struct user {
    var firstName: String
    var lastName: String
    var email: String
    var age: Int
    var height: Double
    var weight: Double
}

class UserData {
    static var testData: user = user(firstName: "John", lastName: "Doe", email: "jdoe@sfu.ca", age: 24, height: 183.0, weight: 200.0)
}
