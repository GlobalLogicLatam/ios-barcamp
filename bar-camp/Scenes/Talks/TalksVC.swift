//
//  TalksViewController.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/30/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit
import GLCommons
import SwiftSpinner


protocol TalksVCInput {
    
    /// Makes UI updates with the provided talk time view models
    ///
    /// - parameter viewModel: Talk times view model
    func displayTalkTimes(viewModel: TalksVM)
    
    /// Make UI updates when talk has been created
    func displayTalkCreated()
    
    /// Makes UI updates when a talk image has been downloaded
    ///
    /// - parameter image: The talk image
    /// - parameter url:   The image url
    func displayTalkImage(_ image: UIImage, url: String)
    
    /// Makes UI updates when a talk has been marked as delayed
    func displayDelayed()
    
    /// Makes UI updates when user logs out
    func displayLogOut()
    
    /// Makes UI updates when error is found
    ///
    /// - parameter msg: The error message
    func displayError(msg: String)
    
    /// Makes UI updates with the provided config view model
    ///
    /// - parameter config: The config view model
    func displayConfig(_ config: ConfigVM)    
}

protocol TalksVCOutput {
    func fetchConfig()
    func fetchTalkTimes()
    func validateAdmin()
    func createTalk(_ talk: TalkRQ, imageData: Data?)
    func editTalk(_ talk: TalkRQ, imageData: Data?)
    func setDelayedTalk(_ talkId: String, delayed: Bool)
    func deleteTalk(_ talkId: String)
    func logOut()
    func fetchImage(url: String)
    func listenForInternetConnection()    
}

class TalksVC: UINavigationController, TalksVCInput, TalkProtocol {
    var output: TalksVCOutput!
    var router: TalksRouterInput!
    var notyCenter: NotificationCenter!
    
    var vm = TalksVM()
    
    // MARK: Object lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        TalksConfigurator.sharedInstance.configure(viewController: self)
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.doSomethingOnLoad()
        notyCenter = NotificationCenter.default
        //Fetch config when the application enters foreground
        notyCenter.addObserver(self, selector: #selector(fetchConfig), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Fetch config each time the view is presented
        self.fetchConfig()
    }

    
    // MARK: Event handling
    func setupUI() {
        self.router.navigateToTalkTimes()
    }
    
    func updateUI() {
        
        //Update the view model in current subviews
        self.viewControllers.forEach { (view: UIViewController) in
            if var viewController = view as? TalkProtocol {
                viewController.vm = self.vm
                viewController.updateUI()
            }
        }
    }
    
    func doSomethingOnLoad() {
        // NOTE: Ask the Interactor to do some work
        self.output.listenForInternetConnection()
        self.output.validateAdmin()
    }
    
    func fetchConfig() {
        self.output.fetchConfig()
    }

    // MARK: Display logic
    func displayTalkTimes(viewModel: TalksVM) {
        self.vm.sections = viewModel.sections
        self.updateUI()
    }
    
    func displayAdmin(_ isAdmin: Bool) {
        self.vm.isAdmin = isAdmin
    }
    
    func displayTalkCreated() {
        HideLoader()
        self.router.getBackToTalkList()
    }
    
    func displayDelayed() {
        self.updateUI()
    }
    
    func displayLogOut() {
        self.router.navigateToLogin()
    }
    
    func displayError(msg: String) {
        HideLoader()
        self.showError(msg: msg)
    }

    func displayTalkImage(_ image: UIImage, url: String) {
        self.vm.cachedImages[url] = image
        self.updateUI()
    }
    
    func displayInternet(available: Bool) {
        self.vm.intetnetAvailable = available
    }
    
    func displayConfig(_ config: ConfigVM) {
        self.vm.config = config
        self.updateUI()
        
        
        if self.vm.config.areTalksAvailable {
            self.output.fetchTalkTimes()
        }
    }
    
    
    func ShowLoader (_ title: String = "", _ block: () -> Void) {
        guard !self.vm.isBusy && self.vm.intetnetAvailable else { return }
        self.vm.isBusy = true
        SwiftSpinner.show(title, animated: true)
        block()
    }
    
    func HideLoader () {
        self.vm.isBusy = false
        SwiftSpinner.hide()
    }
    
    deinit {
        notyCenter.removeObserver(self)
    }
    
    
}

// MARK: TalkTimesDelegate

extension TalksVC: TalkTimesDelegate {
    
    func didSelect(sectionIndex: Int, isBreakSlot: Bool) {
        guard !isBreakSlot else { return }
        
        self.vm.sectionIndex = sectionIndex
        self.updateUI()
        self.router.navigateToTalkList()
    }
    
    func didTapLogOut() {
        self.output.logOut()
    }
    
    

}

extension TalksVC: TalkAddDelegate {
    func didTryCreate(talk: TalkVM, imageData: Data?) {
        
        ShowLoader(NSLocalizedString("talk_saving", comment: ""), {
            self.output.createTalk(TalkRQ(vm: talk), imageData: imageData)
        })
    }
    
    func didTryEdit(talk: TalkVM, imageData: Data?) {
        ShowLoader(NSLocalizedString("talk_saving", comment: ""),  {
            self.output.editTalk(TalkRQ(vm: talk), imageData: imageData)
        })
    }
}

// MARK: TalkListDelegate
extension TalksVC: TalkListDelegate {
    func didTapAddTalk() {
        self.vm.talkIndex = nil
        self.vm.editingTalk = false
        self.router.navigateToAddTalk()
    }
    
    func didFetchImage(url: String) {
        self.output.fetchImage(url: url)
    }

    func didTapEditTalk(_ index: Int) {
        self.vm.talkIndex = index
        self.vm.editingTalk = true
        self.router.navigateToEditTalk()
    }

    func didTapDelayTalk(_ index: Int, delayed: Bool) {
        let talk = self.vm.currentSection!.talks[index]        
        self.output.setDelayedTalk(talk.id, delayed: delayed)
    }
    
    func didTapDeleteTalk(_ index: Int) {
        let talk = self.vm.currentSection!.talks[index]
        self.output.deleteTalk(talk.id)
    }
    
    func didTapImage(_ index: Int){
        let talk = self.vm.currentSection!.talks[index]
        if let url = talk.photo, let img = self.vm.cachedImages[url]{
            self.router.showImage(img)
        }
    }
}
