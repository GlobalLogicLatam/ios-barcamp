//
//  ReachabilityWorker.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/27/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import Firebase
import ReachabilitySwift


class ReachabilityWorker {
    
    typealias Block = (_ reachable: Bool) -> Void
    
    var block: Block!
    let reachability: Reachability!
    
    
    init() {
        reachability = Reachability()
    }
    
    func startNotifyting() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
             self.block(true)
        } else {
            self.block(false)
        }
    }

    func stopNotifyting() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }
    
    deinit {
        self.stopNotifyting()
    }
    
}
