//
//  Config.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 11/1/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation


class Config {
    var id: String!
    var endTime: Date
    var eventDate: Date
    var interval: Int
    var startTime: Date
    var rooms: [Room]
    var breaks: [Break]
    
    init(id: String? = nil, endTime: Date, eventDate: Date, interval: Int, startTime: Date, rooms: [Room], breaks: [Break]) {
        self.id = id
        self.endTime = endTime
        self.eventDate = eventDate
        self.interval = interval
        self.startTime = startTime
        self.rooms = rooms
        self.breaks = breaks
    }
    
    //TODO: Put the real default values
    
    class func `default`() -> Config {
        return Config(id: nil,
                  endTime: Date(timeIntervalSince1970: TimeInterval(77400)),
                  eventDate: Date(timeIntervalSince1970: TimeInterval(1478970000)),
                  interval: 1800,
                  startTime: Date(timeIntervalSince1970: TimeInterval(64800)),
                  rooms: [],
                  breaks: [])
    }
    
    
    /// The times slots
    ///
    /// - returns: The amount of time slots
    func timeSlots() -> Int{
        return (Int(endTime.timeIntervalSince1970)-Int(startTime.timeIntervalSince1970))/interval
    }
    
    /// Validates whether the time slot is a break or not.
    ///
    /// - parameter slot: The time slot in unix time
    ///
    /// - returns: true if the slot is a break, otherwise false
    func isBreakSlot(_ slot: Int) -> Bool{
        for brk in self.breaks {
            let min = Int(brk.time.timeIntervalSince1970)
            let max = min+brk.duration - 1
            
            if slot >= min && slot < max {
                return true
            }
            
        }
        
        return false
    }
}
