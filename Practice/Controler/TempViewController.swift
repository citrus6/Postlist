//
//  TempViewController.swift
//  Practice
//
//  Created by Виктор on 05.09.2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import Foundation
import UIKit

class TempViewController : UIViewController {
    var data: [Comment] = []
    var postId: Int?
    var postTitle = ""
    var body = ""
    var url = ""
    var bigImage: UIImage?
    
    var onLoadImage: ((_ bigImage: UIImage) -> ())?
    var imagePicked: ((UIImage) -> Void)?
    
    @IBOutlet weak var tableView: UITableView!
    
    var heightInset = CGFloat(300)
    

    @IBOutlet weak var addNewCommentButton: UIButton!
    @IBOutlet weak var comentCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var imageView = UIImageView()
    var imageSpinner = UIActivityIndicatorView()
  
    
    @IBOutlet weak var tableSpinner: UIActivityIndicatorView!
    
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
//            let zoomViewController = segue.destination as! ZoomViewController
//            if let image = imageView.image {
//                zoomViewController.imageToZoom = image
//            } else {
//                buttonToZoom.isEnabled = false
//            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addNewCommentButton.isHidden = true
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
        imageSpinner.activityIndicatorViewStyle = .gray
        
        
        
        //imageView.image = #imageLiteral(resourceName: "beach-sand-summer-46710")
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.addSubview(imageSpinner)
        
        imageSpinner.translatesAutoresizingMaskIntoConstraints = false
        imageSpinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        imageSpinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        imageSpinner.hidesWhenStopped = true
        tableSpinner.hidesWhenStopped = true
        
        
        if let height = self.navigationController?.navigationBar.bounds.size.height {
            heightInset -= height
        }
        print(heightInset)
        tableView.contentInset = UIEdgeInsetsMake(heightInset, 0, 0, 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        if url != ""{
            downloadImageUrl()
            
        } else if let bigImage = bigImage {
            imageView.image = bigImage
            
            
        } else {
            imageView.image = #imageLiteral(resourceName: "no-image-icon-23501")
            
        }
        
        tableView.estimatedRowHeight = 96
        tableView.rowHeight = UITableViewAutomaticDimension
        
         loadComment()
        
        imagePicked = {[weak self] (result) in
            self?.imageView.image = result
        }
    }
    
    func setupView() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 8).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -8).isActive = true
       
        titleLabel.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: 8).isActive = true
        
         titleLabel.text = postTitle
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + heightInset)
        
        let height = min(max(y, 60), 400)
        
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
    
    
    func downloadImageUrl(){
       
        imageSpinner.isHidden = false
        imageSpinner.startAnimating()
        
        dowloadImage(url: url){ (result) in
            switch result{
            case .succes(let image):
                DispatchQueue.main.async {
                    self.imageSpinner.stopAnimating()
                    self.imageView.alpha = 0
                    self.imageView.image = image!
                    UIView.animate(withDuration: 0.5, animations: {
                        self.imageView.alpha = 1
                        //self.imageSpinner.isHidden = true
                    })
                    
                    
                    //self.stopSpinner()
                    self.onLoadImage?(image!)
                }
            case .failure(let error):
                print(error!)
            }
        }
    }
    
    func loadComment(){
        tableSpinner.startAnimating()
        getPosts(for: postId!){
            (result) in
            switch result {
            case.succes(let posts):
                self.data = posts as! [Comment]
                //self.activityIndicatorView.stopAnimating()
                //self.activityIndicatorView.isHidden = false
                self.addNewCommentButton.isHidden = false
                self.updateTable()
                self.tableSpinner.stopAnimating()
                
            case.failure(let error):
                fatalInternetError(error)
                
            }
        }
    }
    
    func updateTable(){
        tableView.reloadData()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
      //activityIndicatorView.stopAnimating()
      //  activityIndicatorView.isHidden = true
        if data.count == 0{
            
            comentCountLabel.text = "No comments"
        } else{
            comentCountLabel.text = "\(data.count) comments"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = titleLabel.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
}

extension TempViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.text = "Name: \(data[indexPath.row].name)\nEmail: \(data[indexPath.row].email)\n\(data[indexPath.row].body)"
        UIView.animate(withDuration: 0.3, animations: {
            cell?.alpha = 1
        })
        return cell!
    }

}

extension TempViewController:
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
