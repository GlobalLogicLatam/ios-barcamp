//
//  MainNavController.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/25/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import UIKit

class MainNavController: UINavigationController {

    var connectionLB: UILabel!
    static let sharedInstance: MainNavController = {
        let instance = MainNavController(rootViewController: LoginVC.create())
        instance.isNavigationBarHidden = true;

        return instance
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectionLB = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, 	height: 25))
        connectionLB.text = NSLocalizedString("not_internet_connection", comment: "")
        connectionLB.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.6)
        connectionLB.textColor = UIColor.white
        connectionLB.font = UIFont.systemFont(ofSize: 15)
        connectionLB.textAlignment = .center
        connectionLB.layer.borderWidth = 1
        connectionLB.layer.borderColor = UIColor.clear.cgColor
        connectionLB.layer.cornerRadius = 3
        connectionLB.clipsToBounds = true
        
        connectionLB.isHidden = true
        self.view.addSubview(connectionLB)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        connectionLB.center = self.view.center
        var frame = connectionLB.frame
        frame.origin.y = 70
        connectionLB.frame = frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInternetStatus(available: Bool) {
        
        if !available {
            connectionLB.isHidden = false
        } else {
            connectionLB.isHidden = true
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
