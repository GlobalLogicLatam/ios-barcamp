//
//  LoginPresenter.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit

protocol LoginPresenterInput {
    /// Prepare view model when session has been validated
    ///
    /// - parameter validated: true if the session has been validated, otherwise false.
    func presentSession(validated: Bool)
    
    /// Prepare view model when admin has been validated
    ///
    /// - parameter validated: true is an admin, otherwise false.
    func presentAdmin(validated: Bool)
    
    /// Prepare view model when an error has ocurred
    ///
    /// - parameter msg: The error information
    func presentError(msg: String)
        
    /// Prepare view model when the internet status has changed
    ///
    /// - parameter available: true if internet connection is available, otherwise false
    func presentInternet(available: Bool)
}

protocol LoginPresenterOutput: class {
    func displaySession(validated: Bool)
    func displayAdmin(validated: Bool)
    func displayError(msg: String)
    func displayInternet(available: Bool)
    
}

class LoginPresenter: LoginPresenterInput {
    weak var output: LoginPresenterOutput!

    // MARK: Presentation logic
    func presentSession(validated: Bool) {
        output.displaySession(validated: validated)
    }
    
    func presentAdmin(validated: Bool) {
        output.displayAdmin(validated: validated)
    }
    
    func presentError(msg: String) {
        output.displayError(msg: msg)
    }
    
    func presentInternet(available: Bool) {
        self.output.displayInternet(available: available)
    }

    
}
