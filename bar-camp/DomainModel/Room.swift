//
//  Room.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 11/1/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation

class Room {
    var id: String!
    var name: String?
    
    init(id: String? = nil, name: String?) {
        self.id = id
        self.name = name
    }
}
