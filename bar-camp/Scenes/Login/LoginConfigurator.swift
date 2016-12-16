//
//  LoginConfigurator.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit

// MARK: Connect View, Interactor, and Presenter

extension LoginVC: LoginPresenterOutput {
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        router.passDataToNextScene(segue: segue)
    }
}

extension LoginInteractor: LoginVCOutput {}

extension LoginPresenter: LoginInteractorOutput {}

class LoginConfigurator {

    // MARK: Object lifecycle

    static var sharedInstance = LoginConfigurator()

    private init() {}

    // MARK: Configuration

    func configure(_ viewController: LoginVC) {
        let router = LoginRouter()
        router.viewController = viewController

        let presenter = LoginPresenter()
        presenter.output = viewController

        let interactor = LoginInteractor()
        interactor.output = presenter

        viewController.output = interactor
        viewController.router = router
    }
}
