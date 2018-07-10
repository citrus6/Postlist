//
//  AddNewPost.swift
//  Practice
//
//  Created by Victor Yanuchkov on 09/07/2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import UIKit

class AddNewPost: UIViewController {

   
    @IBOutlet weak var titleCountLAbel: UILabel!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var bodyCountLabelL: UILabel!
    
    var onAddNewPost: ((_ title: String, _ body: String)->())?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextView.delegate = self
        textViewDidEndEditing(titleTextView)
        bodyTextView.delegate = self
        textViewDidEndEditing(bodyTextView)
    }
    
    func showMessage(title: String, message: String){
        self.present(UIAlertController().validateAlert(title: title, message: message), animated: true, completion: nil)
    }
    
    func checkButtonIsActive(){
        if condenseWhitespace(textView: titleTextView) && condenseWhitespace(textView: bodyTextView){
            addBarButton.isEnabled = true
        } else{
            addBarButton.isEnabled = false
        }
    }
    
    func condenseWhitespace(textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGray {
            return false
        }
        let components = textView.text.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty}
        return !components.isEmpty
    }
  
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func add(_ sender: Any) {
        if titleTextView.text.count > 60 {
            showMessage(title: "Incorrect title", message: "Write less than 60 symbol")
            return
        }
        if bodyTextView.text.count > 1000 {
            showMessage(title: "Incorrect body", message: "Write less than 60 symbol")
            return
        }
        onAddNewPost?(titleTextView.text, bodyTextView.text)
        dismiss(animated: true, completion: nil)
        
    }
    
}


extension AddNewPost: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.textColor = UIColor.lightGray
            if titleTextView.text.isEmpty{
                textView.text = "Title"
            } else if bodyTextView.text.isEmpty{
                textView.text = "Your post"
            }
            
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        checkButtonIsActive()
        if titleTextView.textColor != UIColor.lightGray{
            titleCountLAbel.text = "\(titleTextView.text.count)/60"
        }
        if bodyTextView.textColor != UIColor.lightGray{
            bodyCountLabelL.text = "\(bodyTextView.text.count)/1000"
        }
    }
}
