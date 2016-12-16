//
//  LogicModels.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit

struct LoginVM {
    
    enum LoginSingIn {
        case Anonymous
        case Admin
        case Facebook
    }
    
    var signIn = LoginSingIn.Anonymous
    var isBusy = false
    var intetnetAvailable = true
    
}

enum AuthError: Swift.Error, CustomStringConvertible {
    
    case wrongPassword(NSError)
    case invalidPermisions(NSError)
    case userDisabled(NSError)
    case operationNotAllowed(NSError)
    case invalidEmail(NSError)
    case userNotFound
    case networkError(NSError)
    case unknownFailure(NSError)
    
    public var description: String {
        switch self {
        case .wrongPassword(_): return NSLocalizedString("logic_invalid_password", comment: "")
        case .userDisabled(let er): return er.localizedDescription
        case .operationNotAllowed(let er): return er.localizedDescription
        case .invalidEmail(let er): return er.localizedDescription
        case .userNotFound(): return "User not found";
        case .networkError(let er): return er.localizedDescription
        case .invalidPermisions(let er): return er.localizedDescription
        case .unknownFailure(let er): return er.localizedDescription
        }
    }
}
