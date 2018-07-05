
import UIKit

struct CellDate {
    let message: String?
}

class TableViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NetworkManager.Item]()

    override func prepare(for seque: UIStoryboardSegue, sender: Any?){
        if seque.identifier == "showPost" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
               let itemDescription = seque.destination as! ItemDescriptionViewController
                itemDescription.postId = data[indexPath.row].id
                itemDescription.postTitle = data[indexPath.row].title
                itemDescription.body = data[indexPath.row].body
       
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        tableView.dataSource = self
        NetworkManager.getItems(view: self)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
}
