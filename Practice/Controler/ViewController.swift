
import UIKit
import GoogleSignIn

struct CellDate {
    let message: String?
}

class TableViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    var data = [Post]()
    var imageLink = [Photo]()
    var loadedImage = [UIImage?]()
    var loadedLargeImage = [UIImage?]()
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showPost" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                let itemDescription = segue.destination as! ItemDescriptionViewController
                itemDescription.postId = data[indexPath.row].id
                itemDescription.postTitle = data[indexPath.row].title!
                itemDescription.body = data[indexPath.row].body!
                
                let index = imageLink.index(where: {$0.id == indexPath.row+1 })
                
                if let index = index{
                    if let bigImage = loadedLargeImage[index] {
                        itemDescription.bigImage = bigImage
                    } else {
                        itemDescription.url = imageLink[index].url
                        itemDescription.onLoadImage = {(bigImage) in
                            self.loadedLargeImage.insert(bigImage, at: index)
                            print(self.loadedLargeImage)
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
                        fatalError(error.localizedDescription)
                    }
                    
                    
                }
                self.data.append(item)
                self.tableView.reloadData()
            }
        } else if segue.identifier == "startScreeen" {
            
            User.email = ""
            saveUserData()
            GIDSignIn.sharedInstance().signOut()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        getPosts(){
            (result) in
            switch result {
            case.succes(let posts):
                self.data = posts as! [Post]
                self.loadedImage = Array(repeating: nil, count: self.data.count)
                self.loadedLargeImage = Array(repeating: nil, count: self.data.count)
                self.updateData()
                print("data: \(self.data.count), loadedImage: \(self.loadedImage.count)")
            case.failure(let error):
                fatalError("error: \(error.localizedDescription)")
                
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
    
    func setImage(forCell cell: MainScreenTableViewCell, url: String, idForCache id: Int){
        dowloadImage(url: url){ (result) in
            switch result{
            case .succes(let image):
                DispatchQueue.main.async {
                    cell.imageTitle.image = image
                    self.loadedImage[id-1] = image
                    
                }
            case .failure(let error):
                print(error!)
            }
            
        }
        
    }
    
    func addNewImageLink(id: Int , cell: MainScreenTableViewCell){
        
        getPhoto(id: id){ (result) in
            switch result{
            case .succes(let photoLink):
                self.imageLink.append(photoLink)
                
                self.setImage(forCell: cell, url: photoLink.thumbnailUrl, idForCache: id)
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! MainScreenTableViewCell
        cell.labelTitle.text = data[indexPath.row].title
        
        
        if let image = loadedImage[indexPath.row] {
            cell.imageTitle.image = image
        } else {
            addNewImageLink(id: indexPath.row+1, cell: cell)
        }
        
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
