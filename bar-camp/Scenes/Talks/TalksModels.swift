//
//  TalksModels.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/30/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit


enum DataError: Error, CustomStringConvertible {

    case permissionDenied(NSError)
    case unknownFailure(NSError)
    
    public var description: String {
        switch self {
        case .permissionDenied(let er): return er.localizedDescription
        case .unknownFailure(let er): return er.localizedDescription
        }
    }
    
}

struct TalksVM {
    var isAdmin = false
    var sections = [TalkListSection]()
    var sectionIndex: Int!
    var talkIndex: Int!
    var editingTalk = false
    var cachedImages = [String: UIImage]()
    var isBusy = false
    var intetnetAvailable = true
    var config = ConfigVM()

    
    init(_ sections: [TalkListSection] = [TalkListSection](),sectionIndex : Int! = nil, talkIndex: Int! = nil) {
        self.sections = sections
        self.sectionIndex = sectionIndex
        self.talkIndex = talkIndex
    }
    
    var currentSection: TalkListSection? {
        get { return sections[sectionIndex] }
    }
    
    var currentTalk: TalkVM? {
        get { return sections[sectionIndex].talks[talkIndex] }
    }
    
    func image(url: String?) -> UIImage? {
        if let _url = url, let image = self.cachedImages[_url] {
            return image
        }
        return nil
    }
    
    //TODO: Move these methods to the interactor, refactor is needed
    func isSectionFull() -> Bool{        
        return sections[sectionIndex].talks.count >= config.rooms.count
    }
    //TODO: Move these methods to the interactor, refactor is needed
    func isRoomAvailable(_ name: String) -> Bool {
        
        var cr: String? = nil
        if editingTalk {
            cr = currentTalk?.roomName
        }
        
        
        if let _ = sections[sectionIndex].talks.first(where: { $0.roomName == name && $0.roomName != cr }) {
            return false;
        }
        
        return true
    }
    
}

struct TalkListSection {
    let dateString: String
    let timestamp: Int
    let isBreak: Bool
    var talks: [TalkVM]
}

struct TalkVM: Equatable {
    let id: String!
    let name: String
    let timestamp: Int
    let speakerName: String
    let twitterId: String
    let roomName: String
    let desc: String
    var delayed: Bool
    let photo: String?
    
    init(id: String? = nil,
         name: String,
         timestamp: Int,
         speakerName: String,
         twitterId: String,
         roomName: String,
         desc: String,
         delayed: Bool,
         photo: String? = nil) {
        
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.speakerName = speakerName
        self.twitterId = twitterId
        self.roomName = roomName
        self.desc = desc
        self.delayed = delayed
        self.photo = photo
    }
    
    var formattedTwId: String {        
        return twitterId.hasPrefix("@") ? twitterId : "@\(twitterId)"
    }
    
}
func ==(lhs: TalkVM, rhs: TalkVM) -> Bool {
    
    return lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.timestamp == rhs.timestamp &&
    lhs.speakerName == rhs.speakerName &&
    lhs.roomName == rhs.roomName &&
    lhs.desc == rhs.desc &&
    lhs.delayed == rhs.delayed &&
    lhs.photo == rhs.photo
}


struct TalkRQ {
    let id: String!
    let name: String
    let timestamp: Int
    let speakerName: String
    let twitterId: String
    let roomName: String
    let desc: String
    var delayed: Bool
    let photo: String?
    
    init(vm: TalkVM) {
        self.id = vm.id
        self.name = vm.name
        self.timestamp = vm.timestamp
        self.speakerName = vm.speakerName
        self.twitterId = vm.twitterId
        self.roomName = vm.roomName
        self.desc = vm.desc
        self.delayed = vm.delayed
        self.photo = vm.photo
    }
}

struct ConfigVM {
    let rooms: [String]
    let startDate: Date?
    let startDateString: String
    init(rooms: [String] = [], startDate: Date? = nil, startDateString: String = "") {
        self.rooms = rooms
        self.startDate = startDate
        self.startDateString = startDateString
    }
    
    var areTalksAvailable: Bool {
        
        if let start = startDate {
            return start.timeIntervalSince(Date()) < 0
        } else {
            return false
        }
    }
    
}

struct TalkTimesRP {
    let talks: [Talk]
    let config: Config    
}



