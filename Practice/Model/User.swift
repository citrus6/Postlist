import Foundation
import UIKit

class User  {

    static var isLoggin = true
    static var email = ""
}

func documentsDirectory() -> URL{
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func dataFilePath() -> URL{
    return documentsDirectory().appendingPathComponent("Postlists.plist")
}

func saveUserData() {
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: data)
    archiver.encode(User.email, forKey: "UserEmail")
    archiver.finishEncoding()
    data.write(to: dataFilePath(), atomically: true)
}

func loadUserData(){
    let path = dataFilePath()
    if let data = try? Data(contentsOf: path){
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        User.email = unarchiver.decodeObject(forKey: "UserEmail") as! String
    }
    
}
