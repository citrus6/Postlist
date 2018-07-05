//
//  AddItemViewController.swift
//  Practice
//
//  Created by Victor Yanuchkov on 03/07/2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import Foundation
import UIKit

class AddItemViewController: UITableViewController {
    
   
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var postBodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextView.text = "Title"
        titleTextView.textColor = UIColor.lightGray
        emailTextView.text = "Your email"
        emailTextView.textColor = UIColor.lightGray
        postBodyTextView.text = "Your message"
        postBodyTextView.textColor = UIColor.lightGray
        emailTextView.delegate = self
        postBodyTextView.delegate = self
     

   
    }
    
    @IBAction func cancel(){
        dismiss(animated: true, completion: nil)
    }
    @IBAction func done(){
        
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
}

extension AddItemViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            if emailTextView.text.isEmpty{
                textView.text = "Your Email"
                
            }
            if postBodyTextView.text.isEmpty{
                textView.text = "Your message"
            }
            if titleTextView.text.isEmpty{
                textView.text = "Title"
                
            }
        }
    }
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








