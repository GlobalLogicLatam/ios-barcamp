//
//  SocialViewController.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/3/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit
import TwitterKit

class SocialVC: TWTRTimelineViewController, Customizable {
    
    // MARK: Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.setStatusBarColor(UIColor(colorHex: Color.red.default))        
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let client = TWTRAPIClient()
        let dataSource = TWTRSearchTimelineDataSource.init(searchQuery: "barcampmdq #barcampmdq", apiClient: client)
        dataSource.topTweetsOnly = false
        self.dataSource = dataSource
        self.setupUI()
    }
    
    func setupUI() {
        self.showTweetActions = false
        self.title = "#BarcampMDQ"
        let post =  UIBarButtonItem.init(title: NSLocalizedString("post_tweet", comment: ""), style: .plain, target: self, action: #selector(sendTweet))
        
        var attr = [NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        if #available(iOS 8.2, *) {
            attr = [NSFontAttributeName:  UIFont.systemFont(ofSize: 17, weight:UIFontWeightMedium)]
        }
        
        post.setTitleTextAttributes(attr, for: .normal)
        self.navigationItem.rightBarButtonItem = post
        
    }
    
    func sendTweet() {
        let composer = TWTRComposer()
        composer.setText("#BarcampMDQ")
        composer.show(from: self) { result in
            if (result == TWTRComposerResult.cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")                
            }
        }
    }
    
    func updateUI() {
        
    }
    


}
