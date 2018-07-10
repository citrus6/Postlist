import Foundation
import UIKit

class AddItemViewController: UIViewController {
    
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var bodyCountLabel: UILabel!
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var addButton: UIButton!
    var onSave: ((_ title: String, _ email: String, _ body: String) -> ())?
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addComment(_ sender: Any) {
        if titleTextView.text.count > 60 {
            showMessage(title: "Incorrect title", message: "Write less than 60 symbol")
            return
        }
        if !validateEmail(string: emailTextView.text) {
            showMessage(title: "Incorrect email", message: "Email not valid, please input real email")
            return
        }
        if bodyTextView.text.count > 1000{
            showMessage(title: "Incorrect body", message: "Please write less than 60 symbol")
            return
        }
        
        onSave?(titleTextView.text, emailTextView.text, bodyTextView.text)
        dismiss(animated: true)
    }
    
    func showMessage(title: String, message: String){
        self.present(UIAlertController().validateAlert(title: title, message: message), animated: true, completion: nil)
    }
    
    func checkButtonIsActive(){
        if condenseWhitespace(textView: titleTextView) && condenseWhitespace(textView: emailTextView) && condenseWhitespace(textView: bodyTextView)
        {
            addButton.isEnabled = true
        } else {
            addButton.isEnabled = false
        }
    }
    
    func validateEmail(string: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: string)
    }
    
    func condenseWhitespace(textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGray {
            return false
        }
        let components = textView.text.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty}
        return !components.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 8
        popupView.layer.masksToBounds = true
        titleTextView.text = "Title"
        titleTextView.textColor = UIColor.lightGray
        emailTextView.text = "Your Email"
        emailTextView.textColor = UIColor.lightGray
        bodyTextView.text = "Your message"
        bodyTextView.textColor = UIColor.lightGray
        titleTextView.delegate = self
        emailTextView.delegate = self
        bodyTextView.delegate = self
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
            } else if bodyTextView.text.isEmpty{
                textView.text = "Your message"
            } else if titleTextView.text.isEmpty{
                textView.text = "Title"
            }
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        checkButtonIsActive()
        if titleTextView.textColor != UIColor.lightGray{
            titleCountLabel.text = "\(titleTextView.text.count)/60"
            
        }
        if bodyTextView.textColor != UIColor.lightGray{
            bodyCountLabel.text = "\(bodyTextView.text.count)/1000"
        }
    }
}


