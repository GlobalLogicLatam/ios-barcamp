//
//  Talk.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/31/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation

class Talk {
    let id: String!
    let name: String?
    let timestamp: Int?
    let date: Date?
    let speakerName: String?
    let twitterId: String?
    let roomName: String?
    let desc: String?
    var delayed: Bool
    var photo: String?
    
    init(id: String?,
         name: String?,
         timestamp: Int?,
         date: Date?,
         speakerName: String?,
         twitterId: String?,
         desc: String?,
         roomName: String?, delayed: Bool,
         photo: String?) {
        
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.date = date
        self.speakerName = speakerName
        self.twitterId = twitterId
        self.roomName = roomName
        self.desc = desc
        self.delayed = delayed
        self.photo = photo
    }
}
