
import UIKit

class ItemDescriptionViewController: UIViewController, UITableViewDataSource {
    
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    var postId: Int?
    var postTitle = ""
    var body = ""
    
    
    
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var data: [NetworkManager.Comments] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "newComment" {
            let popup = segue.destination as! AddItemViewController
            popup.onSave = { (title, email, body) in
                let id = self.data.count + 1
                let comment = NetworkManager.Comments(id: id, name: title, email: email, body: body)
                self.data.append(comment)
                self.tableView.reloadData()
            }
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.getComments(id: postId!, view: self)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = .none
        self.activityIndicatorView = activityIndicatorView
        setupLayout()
        
        textViewDidChange(titleTextView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if data.count == 0  {
            tableView.separatorStyle = .none
            activityIndicatorView.startAnimating()
        } else {
            tableView.separatorStyle = .singleLine
            
        }
    }
    
    func updateTable(){
        tableView.reloadData()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        if data.count == 0{
            activityIndicatorView.stopAnimating()
            
        }
    }
    
    private func setupLayout(){
        titleTextView.backgroundColor = .lightGray
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.font = UIFont.preferredFont(forTextStyle: .headline)
        titleTextView.textAlignment = NSTextAlignment.center
        titleTextView.text = postTitle
        titleTextView.delegate = self
        titleTextView.isScrollEnabled = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        bodyLabel.text = body
        bodyLabel.textAlignment = NSTextAlignment.natural
        [
            titleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ].forEach{$0.isActive = true}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.titleTextView.text = "Name: \(data[indexPath.row].name)\nEmail: \(data[indexPath.row].email)\n\(data[indexPath.row].body)"
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
        
    }
    
}

extension ItemDescriptionViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height{
                constraint.constant = estimatedSize.height
            }
        }
        
    }
}









