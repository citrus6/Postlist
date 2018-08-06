
import UIKit
import GoogleSignIn

struct CellDate {
    let message: String?
}

class TableViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
  
    
    var data = [Post]()
    var imageLink = [Photo?]()
    var loadedImage = [UIImage?]()
    var loadedLargeImage = [UIImage?]()
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showPost" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                let itemDescription = segue.destination as! ItemDescriptionViewController
                tableView.deselectRow(at: indexPath, animated: false)
                itemDescription.postId = data[indexPath.row].id
                itemDescription.postTitle = data[indexPath.row].title!
                itemDescription.body = data[indexPath.row].body!
                if loadedLargeImage.count > indexPath.row{
                    if let bigImage = loadedLargeImage[indexPath.row] {
                        itemDescription.bigImage = bigImage
                    } else {
                        itemDescription.url = (imageLink[indexPath.row]?.url) ?? "" 
                        itemDescription.onLoadImage = {(bigImage) in
                            self.loadedLargeImage[indexPath.row] = bigImage
                            self.loadedImage[indexPath.row] = bigImage
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        } else if segue.identifier == "newPost" {
            let navigationController = segue.destination as! UINavigationController
            
            let addView = navigationController.topViewController as! AddNewPost
            addView.onAddNewPost = {(title, body) in
                let id = self.data.count + 1
                let item = Post(id: id, title: title, body: body)
                submitPost(post: item){ (error) in
                    if let error = error {
                        fatalInternetError(error)
                        
                    }
                    
                    
                }
                self.data.append(item)
            
                self.tableView.reloadData()
            }
        }
        
    }
    
    @IBAction func logInTap(_ sender: Any) {
        let alert = UIAlertController(title: "LogOut", message: "You are shure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "LogOut", style: .default, handler: logOutActions))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func logOutActions(action: UIAlertAction){
   
                User.getUser()?.email = nil
                User.getUser()?.isLoggedIn = false
                saveUserData(user: User.getUser()!)
                GIDSignIn.sharedInstance().signOut()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextViewController = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
                self.present(nextViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        getPosts(){
            (result) in
            switch result {
            case.succes(let posts):
                self.data = posts as! [Post]
                
                self.data = self.data.filter({$0.title != nil})
               
                self.imageLink = Array(repeating: nil, count: self.data.count)
                self.loadedImage = Array(repeating: nil, count: self.data.count)
                self.loadedLargeImage = Array(repeating: nil, count: self.data.count)
                self.updateData()
                
            case.failure(let error):
                fatalInternetError(error)
                
            }
        }
        
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
    
    func setImage(forCell cell: MainScreenTableViewCell, url: String, idForCache id: Int, complition:@escaping (_: UIImage)->()?){
        dowloadImage(url: url){ (result) in
            
            switch result{
            case .succes(let image):
                DispatchQueue.main.async {
                    self.loadedImage[id-1] = image
                    complition(image!)
                }
            case .failure(let error):
                print(error!)
            }
            
        }
        
    }
    

    
    func addNewImageLink(id: Int , cell: MainScreenTableViewCell, indexPath: IndexPath){
        
        if let index = imageLink.index(where: {$0?.id == id})  {
            setImage(forCell: cell, url: (imageLink[index]?.thumbnailUrl)!, idForCache: id){(result) in
                cell.imageTitle.image = result
               
            }
        } else {
            getPhoto(id: id){ (result) in
                switch result{
                case .succes(let photoLink):
                    
                    self.imageLink[id-1] = photoLink
                   
                    self.setImage(forCell: cell, url: photoLink.thumbnailUrl, idForCache: id){(result) -> Void in
                        
                        if ((self.tableView.indexPathsForVisibleRows?.contains(indexPath))!) && cell.imageTitle.image != result {
                            cell.imageTitle.alpha = 0
                            cell.imageTitle.image = result
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.imageTitle.alpha = 1
                            })
                            cell.spinner.stopAnimating()
                            cell.spinner.isHidden = true
                        }
                         
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! MainScreenTableViewCell
        cell.imageTitle.layer.cornerRadius = 10
        cell.imageTitle.layer.masksToBounds = true
        cell.labelTitle.text = data[indexPath.row].title
        cell.spinner.translatesAutoresizingMaskIntoConstraints = false
        if indexPath.row < loadedImage.count{
            if let image = loadedImage[indexPath.row] {
                
                cell.spinner.stopAnimating()
                cell.spinner.isHidden = true
                
                cell.imageTitle.image = image
            } else {
                
                cell.imageTitle.image = UIImage()
                cell.spinner.centerXAnchor.constraint(equalTo: cell.imageTitle.centerXAnchor).isActive = true
                cell.spinner.centerYAnchor.constraint(equalTo: cell.imageTitle.centerYAnchor).isActive = true
                cell.spinner.isHidden = false
                cell.spinner.startAnimating()
            
                addNewImageLink(id: indexPath.row+1, cell: cell, indexPath: indexPath)
            }
        } else {
            cell.imageTitle.image = #imageLiteral(resourceName: "no-image-icon-23501")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        data.remove(at: indexPath.row)
        imageLink.remove(at: indexPath.row)
        loadedImage.remove(at: indexPath.row)
        loadedLargeImage.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}


