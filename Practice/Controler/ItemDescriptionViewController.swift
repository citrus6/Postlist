
import UIKit

class ItemDescriptionViewController: UIViewController, UITableViewDataSource {
    
    var onLoadImage: ((_ bigImage: UIImage) -> ())?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var postId: Int?
    var postTitle = ""
    var body = ""
    var url = ""
    var bigImage: UIImage?
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var bigImageImageView: UIImageView!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonToZoom: UIButton!
    
    var data: [Comment] = []
    
    var imagePicked: ((UIImage) -> Void)?
    
    var observer: Any!
    
    var cameraButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
        button.setImage(#imageLiteral(resourceName: "camera_icon"), for: .normal)
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        return button
        
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "newComment" {
            let popupVc = segue.destination as! AddItemViewController
            popupVc.onSave = { (title, email, body) in 
                let id = self.data.count + 1
                let comment = Comment(id: id, name: title, email: email, body: body)
                self.data.append(comment)
                self.updateTable()
            }
        }  else if segue.identifier == "zoomScreen" {
            let zoomViewController = segue.destination as! ZoomViewController
            if let image = bigImageImageView.image {
                zoomViewController.imageToZoom = image
            } else {
                buttonToZoom.isEnabled = false
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func stopSpinner(){
        self.spinner.stopAnimating()
        self.spinner.isHidden = true
    }
    
    func downloadImageUrl(){
        dowloadImage(url: url){ (result) in
            switch result{
            case .succes(let image):
                DispatchQueue.main.async {
                    self.bigImageImageView.alpha = 0
                    self.bigImageImageView.image = image!
                    UIView.animate(withDuration: 0.5, animations: {
                        self.bigImageImageView.alpha = 1
                    })
                    self.stopSpinner()
                    self.onLoadImage?(image!)
                }
            case .failure(let error):
                print(error!)
            }
        }
    }
    
    func loadComment(){
        getPosts(for: postId!){
            (result) in
            switch result {
            case.succes(let posts):
                self.data = posts as! [Comment]
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = false
                
                self.updateTable()
                
            case.failure(let error):
                fatalInternetError(error)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        if url != ""{
            downloadImageUrl()
        } else if let bigImage = bigImage {
            bigImageImageView.image = bigImage
            
            stopSpinner()
        } else {
            bigImageImageView.image = #imageLiteral(resourceName: "no-image-icon-23501")
            
            stopSpinner()
        }
        
        tableView.estimatedRowHeight = 96
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadComment()
        bodyTextView.isEditable = false
        titleTextView.isEditable = false
        
        bigImageImageView.layer.cornerRadius = 10
        bigImageImageView.layer.masksToBounds = true
        textViewDidChange(titleTextView)
        textViewDidChange(bodyTextView)
        setupLayout()
        
        imagePicked = {[weak self] (result) in
            self?.bigImageImageView.image = result
        }
        listenForBackgroundNotification()
        
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
    
    @objc func showActionSheet() {
        let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.takePhotoWithCamera()
        }))
        action.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.choosePhotoFromLibrary()
        } ))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(action, animated: true)
    }
    
    func updateTable(){
        tableView.reloadData()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        if data.count == 0{
            
            commentsCount.text = "No comments"
        } else{
            commentsCount.text = "\(data.count) comments"
        }
    }
    
    private func setupLayout(){
        titleTextView.backgroundColor = UINavigationBar.appearance().barTintColor
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.font = UIFont.preferredFont(forTextStyle: .headline)
        titleTextView.textAlignment = NSTextAlignment.center
        titleTextView.text = postTitle
        titleTextView.delegate = self
        titleTextView.isScrollEnabled = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        
        bodyTextView.text = body
        bodyTextView.isScrollEnabled = false
        textViewDidChange(bodyTextView)
        
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.textAlignment = NSTextAlignment.natural
        bigImageImageView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(cameraButton)
        
        buttonToZoom.translatesAutoresizingMaskIntoConstraints = false
        buttonToZoom.alpha = 1
        
        
        [
            titleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleTextView.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleTextView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            headerView.topAnchor.constraint(equalTo: tableView.topAnchor),
            headerView.leftAnchor.constraint(equalTo: tableView.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: tableView.rightAnchor),
            bigImageImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 2),
            bigImageImageView.heightAnchor.constraint(equalToConstant: 150),
            bigImageImageView.widthAnchor.constraint(equalToConstant: 150),
            bigImageImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            buttonToZoom.leftAnchor.constraint(equalTo: bigImageImageView.leftAnchor),
            buttonToZoom.rightAnchor.constraint(equalTo: bigImageImageView.rightAnchor),
            buttonToZoom.topAnchor.constraint(equalTo: bigImageImageView.topAnchor),
            buttonToZoom.bottomAnchor.constraint(equalTo: bigImageImageView.bottomAnchor),
            spinner.centerYAnchor.constraint(equalTo: bigImageImageView.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: bigImageImageView.centerXAnchor),
            bodyTextView.topAnchor.constraint(equalTo: bigImageImageView.bottomAnchor),
            bodyTextView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            bodyTextView.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            bodyTextView.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            
            ].forEach{$0.isActive = true}
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.alpha = 0
        cell.titleTextView.text = "Name: \(data[indexPath.row].name)\nEmail: \(data[indexPath.row].email)\n\(data[indexPath.row].body)"
        UIView.animate(withDuration: 0.3, animations: {
            cell.alpha = 1
        })
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
    func listenForBackgroundNotification(){
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in
            
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: false, completion: nil)
                }
            }
            
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

extension ItemDescriptionViewController:
UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func takePhotoWithCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera", message: "Your device don't support camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated:  true)
        }
    }
    
    @objc func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if let theImage = image {
            imagePicked?(theImage)
            onLoadImage?(theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
