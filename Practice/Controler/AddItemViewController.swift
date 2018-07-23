import Foundation
import UIKit

class AddItemViewController: UIViewController {
    
    
    var popupView : UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    var titleTextView : UITextView = {
        var view = UITextView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var emailTextView : UITextView = {
        var view = UITextView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var bodyTextView : UITextView = {
        var view = UITextView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var addButton : UIButton = {
        var button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var cancelButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(popupView)
        popupView.addSubview(titleTextView)
        popupView.addSubview(emailTextView)
        popupView.addSubview(bodyTextView)
        popupView.addSubview(addButton)
        popupView.addSubview(cancelButton)
        popupView.layer.cornerRadius = 8
        popupView.layer.masksToBounds = true
        setupLayout()
        
        cancelButton.setTitle("Cancel", for: .normal)
        addButton.setTitle("Add comment", for: .normal)
        
        titleTextView.text = "Title"
        titleTextView.textColor = UIColor.lightGray
        emailTextView.text = User.getUser()?.email
        
        bodyTextView.text = "Your message"
        bodyTextView.textColor = UIColor.lightGray
        titleTextView.delegate = self
        emailTextView.delegate = self
        bodyTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillremove), name: Notification.Name.UIKeyboardWillHide, object: nil)
        textViewDidChange(titleTextView)
        textViewDidChange(bodyTextView)
        
        addButton.addTarget(self, action: #selector(addComment(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(closeWindow(sender:)), for: .touchUpInside)
        addButton.setTitleColor(UIColor.gray, for: .disabled)
        addButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    private func setupLayout(){
        [
            popupView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            popupView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.heightAnchor.constraint(equalToConstant: 250),
            titleTextView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 8),
            titleTextView.leftAnchor.constraint(equalTo: popupView.leftAnchor),
            titleTextView.rightAnchor.constraint(equalTo: popupView.rightAnchor),
            titleTextView.heightAnchor.constraint(equalToConstant: 50),
            emailTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 8),
            emailTextView.leftAnchor.constraint(equalTo: popupView.leftAnchor),
            emailTextView.rightAnchor.constraint(equalTo: popupView.rightAnchor),
            emailTextView.heightAnchor.constraint(equalToConstant: 50),
            bodyTextView.topAnchor.constraint(equalTo: emailTextView.bottomAnchor, constant: 8),
            bodyTextView.leftAnchor.constraint(equalTo: popupView.leftAnchor),
            bodyTextView.rightAnchor.constraint(equalTo: popupView.rightAnchor),
            bodyTextView.heightAnchor.constraint(equalToConstant: 90),
            cancelButton.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: 8),
            cancelButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 4),
            cancelButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -2),
            addButton.rightAnchor.constraint(equalTo: popupView.rightAnchor, constant: -8),
            addButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 4),
            addButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -2),
            
            ].forEach({$0.isActive = true})
        
    }
    
    var onSave: ((_ title: String, _ email: String, _ body: String) -> ())?
    
    @objc func closeWindow(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func addComment( sender: UIButton!) {
     
        if !validateEmail(string: emailTextView.text) {
            showMessage(title: "Incorrect email", message: "Email not valid, please input real email")
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
    
    
    
    @objc func keyboardWillremove(notification: NSNotification){
        view.frame.origin.y = 0
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification){
        view.frame.origin.y = -120
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
        if textView == titleTextView {
            if textView.text.count > 60 {
                let text = textView.text.prefix(60)
                textView.text = String(text)
            }
        } else if textView == bodyTextView{
            if textView.text.count > 1000{
                let text = textView.text.prefix(1000)
                textView.text = String(text)
            }
        }
        
    }
}



