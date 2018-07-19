import Foundation
import UIKit

class User  {

    var email: String?
    var isLoggedIn = false
    static var user: User?
    
    private init() {
        loadUserData(user: self)
    }
    
    static func getUser() -> User? {
        if user == nil {
            user = User()
        }
        return user
    }
}

func documentsDirectory() -> URL{
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func dataFilePath() -> URL{
    return documentsDirectory().appendingPathComponent("Postlists.plist")
}

func saveUserData(user: User) {
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: data)
    archiver.encode(user.email, forKey: "UserEmail")
    archiver.encode(user.isLoggedIn, forKey: "isLoggin")
    archiver.finishEncoding()
    data.write(to: dataFilePath(), atomically: true)
}

func loadUserData(user: User){
    let path = dataFilePath()
    if let data = try? Data(contentsOf: path){
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        user.email = unarchiver.decodeObject(forKey: "UserEmail") as? String
        user.isLoggedIn = unarchiver.decodeBool(forKey: "isLoggin")
    }
    
}
