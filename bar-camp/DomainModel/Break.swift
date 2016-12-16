//
//  Break.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 11/1/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation


class Break {
    var id: String!
    var duration: Int
    var time: Date

    init(id: String? = nil, duration: Int, time: Date) {
        self.id = id
        self.duration = duration
        self.time = time
    }
}
