//
//  LoginWorker.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol LoginWorkerProtocol {
    
    /// Validates whether the current sesion is valid or not.
    ///
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func validateSession(success: @escaping (User) -> Swift.Void, failure: @escaping (AuthError) -> Swift.Void)

    /// Creates a new session with provided credentials
    ///
    /// - parameter email:    The email value
    /// - parameter password: The password value
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func signIn(email:String, password: String, success: @escaping (User) -> Swift.Void, failure: @escaping (AuthError) -> Swift.Void)
    
    
    /// Creates a new session as anonymous credentials
    ///
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func signInAnonymously(success: @escaping (User) -> Swift.Void, failure: @escaping (AuthError) -> Swift.Void)


    /// Close the current sesion
    ///
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func signOut(success: @escaping () -> Swift.Void, failure: @escaping (AuthError) -> Swift.Void)
}

class LoginWorker: LoginWorkerProtocol{
    
    var auth: FIRAuth? {
        get { return FIRAuth.auth() }
    }
    
    func validateSession(success: @escaping (User) -> Swift.Void, failure: @escaping (AuthError) -> Swift.Void) {
        
        if let _ = self.auth?.currentUser {
            success(User(firUser: FIRAuth.auth()?.currentUser))
        } else {
            failure(AuthError.userNotFound)
        }
    }
    
    func signIn(email:String, password: String, success: @escaping (User) -> Swift.Void, failure: @escaping (AuthError) -> Swift.Void) {

        self.auth?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            
            if let e = error {
                failure(AuthError.new(firebaseError: e))
            } else {
                success(User(firUser: user))
            }
        })
    }
    
    func signInAnonymously(success: @escaping (User) -> Swift.Void, failure: @escaping (AuthError) -> Swift.Void) {
        
        self.auth?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
            if let e = error {
                failure(AuthError.new(firebaseError: e))
            } else {
                success(User(firUser: user))
            }
        })
    }
    
    func signOut(success: @escaping () -> Swift.Void, failure: @escaping (AuthError) -> Swift.Void)  {
        do {
            try self.auth?.signOut()
            success();
        } catch let error {
            failure(AuthError.new(firebaseError: error))
        }
    }
}

extension User {
    init(firUser: FIRUser?) {
        if let user = firUser {
            self.email = user.email ?? ""
            self.admin = !user.isAnonymous
        } else {
            self.email = ""
            self.admin = false
        }
    }
}

extension AuthError {

    static func new(firebaseError: Error) -> AuthError {
        let nsError = firebaseError as NSError
        
        //@see FIRAuthErrors.h
        switch nsError.code {
        case 17005: return .userDisabled(nsError)
        case 17006: return .operationNotAllowed(nsError)
        case 17008: return .invalidEmail(nsError)
        case 17009: return .wrongPassword(nsError)
        case 17011: return .userNotFound
        case 17020: return .networkError(nsError)
        default: return .unknownFailure(nsError)
        }
        
    }
}
