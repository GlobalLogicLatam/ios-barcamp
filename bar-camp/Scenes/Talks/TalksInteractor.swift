//
//  TalksInteractor.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/30/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit

protocol TalksInteractorInput {
    
    /// Fetch a new config
    func fetchConfig()
    
    /// Fetch talks times data
    func fetchTalkTimes()
    
    /// Fetch admin validation
    func validateAdmin()
    
    /// Create a talk with provided data
    ///
    /// - parameter talk:      The talk data
    /// - parameter imageData: The talk image
    func createTalk(_ talk: TalkRQ, imageData: Data?)

    /// Edit a talk with provided data
    ///
    /// - parameter talk:      The talk data
    /// - parameter imageData: The talk image
    func editTalk(_ talk: TalkRQ, imageData: Data?)
    
    /// Change the talk delayed status
    ///
    /// - parameter talkId:  The talk id
    /// - parameter delayed: The talk delayed status
    func setDelayedTalk(_ talkId: String, delayed: Bool)

    /// Delete a talk
    ///
    /// - parameter talkId: The talk Id
    func deleteTalk(_ talkId: String)
    
    
    /// Close the current session
    func logOut()
    
    
    /// Fetch a image with provided parameters
    ///
    /// - parameter url: The image url
    func fetchImage(url: String)
    
    
    /// Listen for internet status changes
    func listenForInternetConnection()    
    
}

protocol TalksInteractorOutput {
    func presentTalkTimes(response: TalkTimesRP)
    func presentAdmin(_ isAdmin: Bool)
    func presentTalkCreated()
    func presentTalkImage(_ image: UIImage, url: String)
    func presentDelayed()
    func presentLogOut()
    func presentError(msg: String)
    func presentInternet(available: Bool)
    func presentConfig(_ config: Config)
    
}

class TalksInteractor: TalksInteractorInput {
    var output: TalksInteractorOutput!
    var talkWorker: TalksWorkerProtocol = TalksWorker()
    var authWorker: LoginWorkerProtocol = LoginWorker()
    var imageCacheWorker: ImageCacheProtocol = ImageCacheWorker()
    let reachabilityWorker = ReachabilityWorker()
    var lastConfig: Config?
    
    
    func listenForInternetConnection() {
        self.reachabilityWorker.block = { [weak self] available in
            self?.output.presentInternet(available: available)
        }
        self.reachabilityWorker.startNotifyting()
    
    }

    // MARK: Business logic
    func fetchConfig() {
        self.talkWorker.getConfig(success: { [weak self] config in
            self?.lastConfig = config
            self?.output.presentConfig(config)
        }) { [weak self] (error:DataError) in
                self?.manageError(error: error)
        }
    }

    
    func fetchTalkTimes() {
        
        self.talkWorker.getTalks(success: {[weak self] (talks: [Talk]) in            
            let config = self?.lastConfig ?? Config.default()
            let params = TalkTimesRP(talks: talks, config: config)
            self?.output.presentTalkTimes(response: params)
            
        }) { [weak self] (er: DataError) in
            self?.manageError(error: er)
        }
    }
    func validateAdmin() {
        self.authWorker.validateSession(success: { [weak self] (user: User) in
            self?.output.presentAdmin(user.admin)
        }) { (error: AuthError) in
            //Avoding to show error
        }
    }
    
    func createTalk(_ talk: Talk) {
        self.talkWorker.createTalk(talk, success: {[weak self] in
            self?.output.presentTalkCreated()
        }) { [weak self] (error: DataError) in
            self?.manageError(error: error)
        }
    }
    
    func editTalk(_ talk: Talk) {
        self.talkWorker.editTalk(talk, success: {[weak self] in
            self?.output.presentTalkCreated()
        }) { [weak self] (error: DataError) in
            self?.manageError(error: error)
        }
    }
    
    func createTalk(_ talk: TalkRQ, imageData: Data?) {

        let _talk = Talk(id: nil,
                         name: talk.name,
                         timestamp: talk.timestamp,
                         date: nil,
                         speakerName: talk.speakerName,
                         twitterId: talk.twitterId,
                         desc: talk.desc,
                         roomName: talk.roomName,
                         delayed: talk.delayed,
                         photo: nil)

        
        if let _data = imageData  {
            self.talkWorker.uploadImage(data: _data, success: { [weak self] (url: String) in
                _talk.photo = url
                self?.createTalk(_talk)
                }, failure: { [weak self] (error: DataError) in
                    self?.manageError(error: error)
            })
        } else {
            self.createTalk(_talk)
        }
    }
    
    func editTalk(_ talk: TalkRQ, imageData: Data?) {
        
        let _talk = Talk(id: talk.id,
                         name: talk.name,
                         timestamp: talk.timestamp,
                         date: nil,
                         speakerName: talk.speakerName,
                         twitterId: talk.twitterId,
                         desc: talk.desc,
                         roomName: talk.roomName,
                         delayed: talk.delayed,
                         photo: talk.photo)
        
        if let _data = imageData {
            self.talkWorker.uploadImage(data: _data, success: { [weak self] (url: String) in
                _talk.photo = url
                self?.editTalk(_talk)
                }, failure: { [weak self] (error: DataError) in
                    self?.manageError(error: error)
            })
        } else {
            self.editTalk(_talk)
        }
    }
    
    func fetchImage(url: String) {
        if self.imageCacheWorker.isImageCache(forKey: url) {
            self.imageCacheWorker.getImage(forKey: url, success: { [weak self] (img: UIImage) in
                self?.output.presentTalkImage(img, url: url)
            })
        } else {
            self.talkWorker.fetchImage(url: url, success: { [weak self] (url: String, data: Data) in
                if let image = UIImage.init(data: data) {
                    self?.imageCacheWorker.cacheImage(key: url, image: image, data: data)
                    self?.output.presentTalkImage(image, url: url)
                } else {
                    print("Error")
                }
                
                }, failure: { (error: DataError) in
                    print("Error")
            })
        }
    }
    
    //TODO: Call the presenter method
    func setDelayedTalk(_ talkId: String, delayed: Bool) {
        self.talkWorker.setDelayedTalk(talkId, delayed: delayed, success: {
            
        }) { [weak self] (error: DataError) in
            self?.manageError(error: error)
        }
    }
    
    //TODO: Call the presenter method
    func deleteTalk(_ talkId: String) {
        self.talkWorker.deleteTalk(talkId, success: {
            
        }) { [weak self] (error: DataError) in
            self?.manageError(error: error)
        }
    
    }
    
    func logOut() {
        self.authWorker.signOut(success: { [weak self] in
            self?.output.presentLogOut()
        }) { [weak self] (e: AuthError) in
            self?.output.presentError(msg: NSLocalizedString("talk_log_out_error", comment: ""))
        }
    }    
    
    //Manage uses cases based on error type
    func manageError(error: DataError) {
        
        switch error {
        case .permissionDenied(_):
            self.output.presentLogOut()
            break
        default:
            self.output.presentError(msg: error.description)
            break
        }
        
    }
    
}
