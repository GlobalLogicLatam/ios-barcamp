//
//  TalksRouter.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/30/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit

protocol TalksRouterInput {
    func navigateToLogin()
    func navigateToTalkTimes()
    func navigateToTalkList()
    func navigateToAddTalk()
    func getBackToTalkList ()
    func navigateToEditTalk()
    func showImage(_ image: UIImage)     
    func passDataToNextScene(segue: UIStoryboardSegue)
}

class TalksRouter: TalksRouterInput {
    weak var viewController: TalksVC!
    var mainNavigator = MainNavController.sharedInstance

    // MARK: Navigation

    func navigateToSomewhere() {
        // NOTE: Teach the router how to navigate to another scene. Some examples follow:

        // 1. Trigger a storyboard segue
        // viewController.performSegueWithIdentifier("ShowSomewhereScene", sender: nil)

        // 2. Present another view controller programmatically
        // viewController.presentViewController(someWhereViewController, animated: true, completion: nil)

        // 3. Ask the navigation controller to push another view controller onto the stack
        // viewController.navigationController?.pushViewController(someWhereViewController, animated: true)

        // 4. Present a view controller from a different storyboard
        // let storyboard = UIStoryboard(name: "OtherThanMain", bundle: nil)
        // let someWhereViewController = storyboard.instantiateInitialViewController() as! SomeWhereViewController
        // viewController.navigationController?.pushViewController(someWhereViewController, animated: true)
    }

    func navigateToLogin() {
        
        let top = self.mainNavigator.topViewController
        
        self.mainNavigator.setViewControllers([LoginVC.create(), top!], animated: true)
        self.mainNavigator.popToRootViewController(animated: true)
    }
    
    func navigateToTalkList() {
        let talkList: TalkListVC!   = TalkListVC.create() as? TalkListVC
        talkList.delegate           = self.viewController
        talkList.vm                 = self.viewController.vm
        self.viewController.pushViewController(talkList!, animated: true)
    }
    
    func navigateToAddTalk() {
        let addTalk: TalkAddVC! = TalkAddVC.create() as? TalkAddVC
        addTalk.delegate        = self.viewController
        addTalk.vm              = self.viewController.vm
        self.viewController.pushViewController(addTalk!, animated: true)
    }
    
    func getBackToTalkList () {
        self.viewController.popViewController(animated: true)
    }

    func navigateToTalkTimes() {
        let timesList: TalkTimesVC! = TalkTimesVC.create() as? TalkTimesVC
        timesList.delegate = self.viewController
        self.viewController.viewControllers = [timesList]
    }
    
    func navigateToEditTalk() {
        let addTalk: TalkAddVC! = TalkAddVC.create() as? TalkAddVC
        addTalk.delegate        = self.viewController
        addTalk.vm              = self.viewController.vm        
        self.viewController.pushViewController(addTalk!, animated: true)
    }
    
    func showImage(_ image: UIImage) {

        let viewer = ImageViewerVC.create() as? ImageViewerVC
        viewer?.image = image
        self.mainNavigator.present(UINavigationController.init(rootViewController: viewer!), animated: true, completion: nil)
    }
    
    
    // MARK: Communication
    func passDataToNextScene(segue: UIStoryboardSegue) {
        // NOTE: Teach the router which scenes it can communicate with

        if segue.identifier == "ShowSomewhereScene" {
            passDataToSomewhereScene(segue: segue)
        }
    }

    func passDataToSomewhereScene(segue: UIStoryboardSegue) {
        // NOTE: Teach the router how to pass data to the next scene

        // let someWhereViewController = segue.destinationViewController as! SomeWhereViewController
        // someWhereViewController.output.name = viewController.output.name
    }
}
