//
//  LoginInteractor.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit

protocol LoginInteractorInput {
    
    /// Creates a new session with the provided credetials.
    ///
    /// - parameter email:    The email value
    /// - parameter password: The email password
    func signIn(_ email: String, password: String)
    

    /// Validates whether there is active session or not
    func validateSession()
    
    /// Validates whether provided email belongs to an admin account
    ///
    /// - parameter email: The email vlaue
    func validateAdmin(email: String)
    
    /// Creates an anonimous session with provided email
    ///
    /// - parameter email: The email value
    func signInAnonymously(email: String)

    /// Start listening for internet connection changes
    func listenForInternetConnection()     
}

protocol LoginInteractorOutput {
    
    func presentSession(validated: Bool)
    func presentAdmin(validated: Bool)
    func presentError(msg: String)
    func presentInternet(available: Bool)    
}

class LoginInteractor: LoginInteractorInput {
    var output: LoginInteractorOutput!
    var worker: LoginWorkerProtocol = LoginWorker()
    var dataWorker: TalksWorkerProtocol = TalksWorker()
    let reachabilityWorker = ReachabilityWorker()
    
    
    func listenForInternetConnection() {
        
        //A block executed on internet status changes
        self.reachabilityWorker.block = { [weak self] available in
            guard let strongSelf = self else { return }
            strongSelf.output.presentInternet(available: available)
        }
        self.reachabilityWorker.startNotifyting()
    }
    
    // MARK: Business logic
    func signIn(_ email: String, password: String) {
        self.worker.signIn(email: email, password: password, success: { [weak self] (user: User) in
            self?.output.presentSession(validated: true)
        }) { [weak self] (error: AuthError) in
            self?.output.presentError(msg: error.description)
        }
    }
    
    func validateSession() {
        self.worker.validateSession(success: { [weak self] (user: User) in
            self?.output.presentSession(validated: true)
        }) { [weak self] (error: AuthError) in
            self?.output.presentSession(validated: false)
        }
    }

    func validateAdmin(email: String) {
        //We validate an admin if a wrong password error is thrown.
        self.worker.signIn(email: email, password: "???????", success: { [weak self] (user: User) in
            self?.output.presentAdmin(validated: true) //it should be never executed
        }) { [weak self] (error: AuthError) in
            
            switch error {
            case .wrongPassword(_): self?.output.presentAdmin(validated: true); break
            case .userNotFound(_): self?.output.presentAdmin(validated: false); break
            default: self?.output.presentError(msg: error.description); break
            }
        }
    }
    func signInAnonymously(email: String) {
        self.worker.signInAnonymously(success: { [weak self] (user: User) in
            //We persist the email for marketing purposes
            self?.dataWorker.addEmail(email: email, success: { [weak self] in
                self?.output.presentSession(validated: true)
            }) { [weak self] (error: DataError) in
                self?.output.presentError(msg: error.description)
            }
        }) { [weak self] (error: AuthError) in
            self?.output.presentError(msg: error.description)
        }
    }    
}
