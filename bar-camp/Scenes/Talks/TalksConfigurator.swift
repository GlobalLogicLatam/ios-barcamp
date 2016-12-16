//
//  TalksConfigurator.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/30/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit

// MARK: Connect View, Interactor, and Presenter

extension TalksVC: TalksPresenterOutput {
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        router.passDataToNextScene(segue: segue)
    }
}

extension TalksInteractor: TalksVCOutput {}

extension TalksPresenter: TalksInteractorOutput {}

class TalksConfigurator {

    // MARK: Object lifecycle

    static var sharedInstance = TalksConfigurator()

    private init() {}

    // MARK: Configuration

    func configure(viewController: TalksVC) {
        let router = TalksRouter()
        router.viewController = viewController

        let presenter = TalksPresenter()
        presenter.output = viewController

        let interactor = TalksInteractor()
        interactor.output = presenter

        viewController.output = interactor
        viewController.router = router
    }
}
