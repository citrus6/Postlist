
import UIKit

struct CellDate {
    let message: String?
}

class TableViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    var data = [NetworkManager.Item]()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showPost" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
               let itemDescription = segue.destination as! ItemDescriptionViewController
                itemDescription.postId = data[indexPath.row].id
                itemDescription.postTitle = data[indexPath.row].title!
                itemDescription.body = data[indexPath.row].body!
            }
        } else if segue.identifier == "newPost" {
            let navigationController = segue.destination as! UINavigationController
            
            let addView = navigationController.topViewController as! AddNewPost
            addView.onAddNewPost = {(title, body) in
                let id = self.data.count + 1
                let item = NetworkManager.Item(id: id, title: title, body: body)
                self.data.append(item)
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        tableView.dataSource = self
        NetworkManager.getItems(view: self)
  
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = .none
        self.activityIndicatorView = activityIndicatorView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if data.count == 0 {
            tableView.separatorStyle = .none
            activityIndicatorView.startAnimating()
        } else {
            tableView.separatorStyle = .singleLine
        }
    }
    
    func updateData(){
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        if data.count == 0{
            activityIndicatorView.stopAnimating()
        }
        UIView.transition(with: tableView, duration: 0.35, options: .transitionFlipFromTop, animations: {self.tableView.reloadData()}, completion: nil)
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        data.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
