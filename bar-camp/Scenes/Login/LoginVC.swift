//
//  LogicViewController.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit
import GLCommons
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftSpinner


protocol LoginVCInput {

    /// Makes UI updates when a session has been validated
    ///
    /// - parameter validated: true if the session is valid, otherwise false
    func displaySession(validated: Bool)
    
    /// Makes UI updates when a admin has been validated
    ///
    /// - parameter validated: true is an admin, otherwise false
    func displayAdmin(validated: Bool)
    
    /// Makes UI updates when a error is found
    ///
    /// - parameter msg: The error message
    func displayError(msg: String)
    
    /// Makes UI updates when internet status has changed
    ///
    /// - parameter available: true if internet is available, otherwise false
    func displayInternet(available: Bool)
}

protocol LoginVCOutput {
    func signIn(_ email: String, password: String)
    func validateSession()
    func validateAdmin(email: String)
    func signInAnonymously(email: String)
    func listenForInternetConnection()
}

class LoginVC: UIViewController, LoginVCInput, Customizable, FBSDKLoginButtonDelegate {
    var output: LoginVCOutput!
    var router: LoginRouter!
    var vm = LoginVM()

    @IBOutlet weak var signInBT: UIButton!
    @IBOutlet weak var signInFacebookBT: FBSDKLoginButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var errorLB: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var alert: PasswordAlert!
    lazy var mainNavigation: MainNavController = {
        return MainNavController.sharedInstance
    }()
    
    //Helper component to avoid keybaord overlaps Textfields
    var keyboardManager: KeyboardManager!
    //Helper component for form validation
    let validator = FormValidator<E>()
    
    // MARK: Object lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        LoginConfigurator.sharedInstance.configure(self)
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardManager = KeyboardManager(contentView: self.scrollView)
        self.output.listenForInternetConnection()
        ShowLoader { self.output.validateSession() }
    }
    

    func setupUI() {
        //Setting up facebook login
        self.signInFacebookBT.readPermissions = ["public_profile", "email", "user_friends"]
        self.signInFacebookBT.delegate = self

        setupFormValidorClosures()
        setupEmailFieldValidation()
        setupEmailFieldUI()
    }
    

    func setupFormValidorClosures() {
        //Clousure called when `FormValidator` reaches error
        self.validator.didFind = { [unowned self] errors in
            if let error = errors.first {
                self.errorLB.isHidden = false
                self.errorLB.text = error.description
            }
        }
        
        //Clousure called when `FormValidator` removes a validation error
        self.validator.didRemove = { [unowned self] errors in
            for _ in errors {
                self.errorLB.isHidden = true
            }
        }
    }
    
    /// Setup email textfield validation rules
    func setupEmailFieldValidation() {
        /// Max/min characters in email input field
        let lg = TextValidator<E>(min: 1, max: 40)
        lg.format = { _ -> (String, String) in
            return (minMsg: NSLocalizedString("logic_required_email", comment: ""), maxMsg: NSLocalizedString("logic_max_chars_email", comment: ""))
        }
        
        /// No empty field validation
        let rq = NonEmptyValidator<E>()
        rq.format = { NSLocalizedString("logic_required_email", comment: "") }
        
        // Email validation
        let ev = EmailValidator<E>()
        ev.format = { _ in return NSLocalizedString("logic_invalid_email", comment: "") }
        
        // Adding validation rules to email input field
        let field = FormField(fieldRules: [rq, ev, lg], eval: .focusOut, fieldInfo: emailTF)
        self.validator.connectUIControl(emailTF, field: field)
    }
    
    
    /// Setup email textfield ui
    func setupEmailFieldUI() {
        
        self.emailTF.leftViewMode = .always
        self.emailTF.textColor = UIColor(colorHex: Color.black.light)
        self.emailTF.leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 20))
        self.emailTF.placeholder = NSLocalizedString("logic_enter_email", comment: "");
        self.errorLB.textColor = UIColor(colorHex: Color.red.default)
        self.errorLB.isHidden = true
        self.emailTF.addEmailStyle()
        self.signInBT.addRedStyle()
    }
    
    func updateUI() {
        
    }
    
    @IBAction func signInAction() {
        if validator.validateAllFields() {
            if vm.signIn == .Admin {
                self.loginAsAdmin()
                return
            }
            
            ShowLoader (NSLocalizedString("logic_signing_in", comment: ""),{ self.output.validateAdmin(email: emailTF.text!); })
        }
    }
    
    
    /// Display the spinner loader and executes a block. If the view is busy or internet connection is not available
    /// the method abort the block execution
    ///
    func ShowLoader (_ title: String = "", _ block: () -> Void) {
        guard !self.vm.isBusy && self.vm.intetnetAvailable else { return }
        self.vm.isBusy = true
        SwiftSpinner.show(title, animated: true)
        block()
    }

    
    /// Hides the spinner loader
    func HideLoader () {
        self.vm.isBusy = false
        SwiftSpinner.hide()
    }
    
    
    func loginAsAdmin() {
        self.alert = PasswordAlert { [weak self] (password: String) in
            guard let strongSelf = self else { return }
            
            //Display error if no password is provided
            if password.isEmpty {
                strongSelf.showError(title: NSLocalizedString("logic_password", comment: ""), msg: NSLocalizedString("logic_empty_password", comment: ""))
                return
            }
            
            strongSelf.ShowLoader {
                strongSelf.output.signIn(strongSelf.emailTF.text!, password: password)
            }
        }
        self.present(self.alert.alert, animated: true, completion: nil)
    }
    
    func loginAnonymously() {
        self.output.signInAnonymously(email: self.emailTF.text!)
    }
    
    // MARK: Event handling
    func displaySession(validated: Bool) {
        HideLoader()
        if validated {
            self.router.navigateToHome()
        }
    }
    
    func displayAdmin(validated: Bool) {
        if validated {
            HideLoader()
            self.vm.signIn = .Admin
            self.loginAsAdmin()
        } else {
            self.vm.signIn = .Anonymous
            self.loginAnonymously()
        }
    }
    
    func displayError(msg: String) {
        HideLoader()
        self.showError(msg: msg)

    }
    func displayInternet(available: Bool) {
        self.vm.intetnetAvailable = available        
        //Notify about internet connection status
        self.mainNavigation.showInternetStatus(available: available)
    }
        
    
    // MARK: Facebook login delegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Swift.Error!) {
        if (result.isCancelled) {
            return
        }
        
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email"])
        
        let requestResults = graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil) {
                let data:[String:AnyObject] = result as! [String : AnyObject]
                let fbUserEmail = data["email"]! as! String
                print(fbUserEmail)
                
                //Signin con mail de facebook
                self.vm.signIn = .Facebook
                self.output.signInAnonymously(email: fbUserEmail)
            }
        })
        print(requestResults)
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}

extension LoginVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Move thes textield above the keyboard if needed
        keyboardManager.activeField = textField
        self.vm.signIn = .Anonymous
    }
    
}

extension UITextField {
    
    func addEmailStyle() {
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 2.0
        self.layer.borderColor = UIColor(colorLiteralRed: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 0.5).cgColor
    }
    
}
