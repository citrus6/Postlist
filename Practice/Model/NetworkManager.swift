import Foundation
import UIKit

class NetworkManager  {
    
    struct Item: Decodable {
        let id: Int
        let title: String
        let body: String
    }
    
    struct Comments: Decodable{
        let id: Int
        let name: String
        let email: String
        let body: String
    }
    
    var jsonData: [Decodable] = []
    
    static func getItems(view: TableViewController){
        guard let url = URL(string:"https://jsonplaceholder.typicode.com/posts") else{
            return
        }
        URLSession.shared.dataTask(with: url) { (data, responce, err) in
            guard let data = data else {return}
            do{
                let courses = try JSONDecoder().decode([Item].self, from: data)
                DispatchQueue.main.async {
                    view.data = courses
                    view.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    view.tableView.reloadData()
                }
                
            } catch let jsonErr{
                print("Error serializing json: ", jsonErr)
            }
            }.resume()
        
    }
    
    static func getComments(id: Int, view: ItemDescriptionViewController){
        guard let url = URL(string:"https://jsonplaceholder.typicode.com/posts/\(id)/comments") else{
            return
            
        }
        URLSession.shared.dataTask(with: url) { (data, responce, err) in
            guard let data = data else {return}
            do{
                let courses = try JSONDecoder().decode([Comments].self, from: data)
                DispatchQueue.main.async {
                    view.data = courses
                    view.tableView.reloadData()
                    view.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                }
                
            } catch let jsonErr{
                print("Error serializing json: ", jsonErr)
            }
            }.resume()
    }
}
