//
//  HomeTBC.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/3/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import UIKit

class HomeTBC: UITabBarController, Customizable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI() {
        let board  = TalksVC.create()
        let social = SocialVC.create()
        self.viewControllers = [board, social]        

        let item0 = self.tabBar.items?[0]
        item0?.title = NSLocalizedString("talk_board", comment: "")
        item0?.image = UIImage.init(named: "ic_board_off")
        item0?.selectedImage = UIImage.init(named: "ic_board_on")

        let item1 = self.tabBar.items?[1]
        item1?.title = "#BarcampMDQ"
        item1?.image = UIImage.init(named: "ic_social_off")
        item1?.selectedImage = UIImage.init(named: "ic_social_on")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func updateUI() {
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
