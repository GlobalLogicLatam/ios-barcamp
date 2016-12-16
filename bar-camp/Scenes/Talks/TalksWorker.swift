//
//  TalksWorker.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/30/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import ObjectMapper


protocol TalksWorkerProtocol {
    
    /// Get the persisted config object
    ///
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func getConfig(success: @escaping (Config) -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)

    /// Get all persisted talk objects
    ///
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func getTalks(success: @escaping ([Talk]) -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)

    
    /// Create a new talk object with provided data and persists it
    ///
    /// - parameter talk:    The talk model
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func createTalk(_ talk:Talk, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)
    
    /// Edit a talk object in the persistence storage with provided data
    ///
    /// - parameter talk:    The talk data
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func editTalk(_ talk:Talk, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)
    
    
    /// Change the delayed status in a talk object and persists it.
    ///
    /// - parameter talkId:  The talk object id
    /// - parameter delayed: The delayed status
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func setDelayedTalk(_ talkId: String, delayed: Bool, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)
    
    /// Delete a talk object from persistent storage
    ///
    /// - parameter talkId:  The talk id
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func deleteTalk(_ talkId: String, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)

    
    /// Create a new email object and persist it.
    ///
    /// - parameter email:   The email value
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func addEmail(email: String, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)

    
    /// Upload a image to a storage engine
    ///
    /// - parameter data:    The image data
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    ///
    func uploadImage(data: Data, success: @escaping (_ imageURL: String) -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)

    
    /// Get a image from a storage engine
    ///
    /// - parameter url:     The image url
    /// - parameter success: A closure to be executed if the task finishes successfully.
    /// - parameter failure: A closure to be executed if the task finishes unsuccessfully.
    func fetchImage(url: String, success: @escaping (_ imageURL: String, _ data: Data) -> Swift.Void, failure: @escaping (DataError) -> Swift.Void)
}

class TalksWorker: TalksWorkerProtocol {

    // MARK: Business Logic
    
    var ref: FIRDatabaseReference = {
        return FIRDatabase.database().reference()
    }()
    
    lazy var storageRef: FIRStorageReference = {
        
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        let dic = NSDictionary.init(contentsOfFile: filePath!)
        let storage = dic!["STORAGE_BUCKET"] as! String
        let hostUrl = "gs://"+storage
        
        return FIRStorage.storage().reference(forURL: hostUrl)
    }()
    
    var talksHandle: FIRDatabaseHandle!
    var configHandle: FIRDatabaseHandle!
    var data: [Talk]!
    var config: Config!
    
    func getConfig(success: @escaping (Config) -> Swift.Void, failure: @escaping (DataError) -> Swift.Void){
        guard self.configHandle == .none else { success(self.config); return }
        
        self.configHandle = self.ref.child("config").observe(.value, with: { [weak self] (config: FIRDataSnapshot) in
            let object: _Config? = FIRHelper.parseObject(from: config)
            guard let strongSelf = self else { return }
            if let object = object {
                strongSelf.config = Config(dto: object)
                success(strongSelf.config!)
            } else {}
            }, withCancel: { (error: Error) in
                failure(DataError.new(firebaseError: error))
        })
    }
    
    func getTalks(success: @escaping ([Talk]) -> Swift.Void, failure: @escaping (DataError) -> Swift.Void){
        
        guard self.talksHandle == .none else { success(self.data); return }
        
        self.talksHandle = self.ref.child("talks").observe(.value, with: { [weak self] (data: FIRDataSnapshot) in
            guard let strongSelf = self else { return }
            let array: [_Talk] = FIRHelper.parseArray(from: data)
            strongSelf.data = array.map{ Talk(dto: $0)}
            success(strongSelf.data)
            }, withCancel: { (error: Error) in
                failure(DataError.new(firebaseError: error))
        })
    }
    
    func createTalk(_ talk:Talk, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void) {
        
        self.ref.child("talks").childByAutoId().setValue(FIRHelper.serialize(dto: talk.dto), withCompletionBlock: { (error: Error?, newRef: FIRDatabaseReference) in
            if let er = error {
                failure(DataError.new(firebaseError: er))
            } else {
                success()
            }
        })
    }
    
    func editTalk(_ talk:Talk, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void) {
        let id: String = talk.id
        self.ref.child("talks/\(id)").setValue(FIRHelper.serialize(dto: talk.dto), withCompletionBlock: { (error: Error?, edit: FIRDatabaseReference) in
            if let er = error {
                failure(DataError.new(firebaseError: er))
            } else {
                success()
            }
        })        
    }
    
    
    func addEmail(email: String, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void) {
        self.ref.child("emails").childByAutoId().setValue(["email": email], withCompletionBlock: { (error: Error?, newRef:FIRDatabaseReference) in
            if let er = error {
                failure(DataError.new(firebaseError: er))
            } else {
                success()
            }            
        })
    
    }
    func setDelayedTalk(_ talkId: String, delayed: Bool, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void) {
        self.ref.child("talks/\(talkId)").updateChildValues(["delayed": delayed], withCompletionBlock: { (error: Error?, edit: FIRDatabaseReference) in
            if let er = error {
                failure(DataError.new(firebaseError: er))
            } else {
                success()
            }
        })
        
    }
    
    
    func deleteTalk(_ talkId: String, success: @escaping () -> Swift.Void, failure: @escaping (DataError) -> Swift.Void) {
        self.ref.child("talks/\(talkId)").removeValue(completionBlock: { (error: Error?, edit: FIRDatabaseReference) in
            if let er = error {
                failure(DataError.new(firebaseError: er))
            } else {
                success()
            }
        })
        
    }
    
    

    func uploadImage(data: Data, success: @escaping (_ imageURL: String) -> Swift.Void, failure: @escaping (DataError) -> Swift.Void) {

        guard let uid = FIRAuth.auth()?.currentUser?.uid else { failure(DataError.permissionDenied(NSError())); return }
        
        let imagePath = "images/\(uid)/\(UInt64(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        self.storageRef.child(imagePath)
            .put(data, metadata: metadata) { [weak self] (metadata, error) in
                guard let strongSelf = self else { return }
                if let error = error {
                    failure(DataError.new(firebaseError: error))
                } else {
                    success(strongSelf.storageRef.child((metadata?.path)!).description)
                }
        }
        
        return
        
        
    }
    
    func fetchImage(url: String, success: @escaping (_ imageURL: String, _ data: Data) -> Swift.Void, failure: @escaping (DataError) -> Swift.Void) {
        FIRStorage.storage().reference(forURL: url).data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading: \(error)")
                return
            } else {
                success(url, data!)
            }
        }
        
    }
        
    deinit {
        if let _ = talksHandle { self.ref.child("talks").removeObserver(withHandle: talksHandle) }
        if let _ = configHandle { self.ref.child("config").removeObserver(withHandle: configHandle) }
    }
}

extension DataError {

    static func new(firebaseError: Error) -> DataError {
        let nsError = firebaseError as NSError
        
        //@see FIRAuthErrors.h
        switch nsError.code {
        case 1: return .permissionDenied(nsError)
        default: return .unknownFailure(nsError)
        }
    }


}

final class FIRHelper {
    
    class func serialize(dto: _Talk) -> [String : Any] {
        return Mapper<_Talk>().toJSON(dto)
    }
    
    class func parseArray<T: FirebaseMappble>(from: FIRDataSnapshot) -> [T] {
        if let object = from.value  {
            return FBArrayTransform<T>().transformFromJSON(object) ?? []
        }
        
        return []
    }
    
    class func parseObject<T: FirebaseMappble>(from: FIRDataSnapshot) -> T? {
        if let object = from.value  {
            //Wrapping the object inside a dictionary to fit the method parameter requirements
            return FBArrayTransform<T>().transformFromJSON(["":object])?.first
        }
        return nil
    }
}

struct _Talk: FirebaseMappble {
    var id: String!
    var name: String?
    var date: Int?
    var speakerName: String?
    var twitterId: String?
    var roomName: String?
    var desc: String?
    var delayed: Bool?
    var photo: String?

    init () {}
    init?(map: Map) { }

    // Mappable
    mutating func mapping(map: Map) {
        name <- map["name"]
        date <- map["date"]
        speakerName <- map["speakerName"]
        twitterId <- map["twitterId"]
        roomName <- map["roomName"]
        desc <- map["description"]
        delayed <- map["delayed"]
        photo <- map["photo"]
    }
    
}



extension Talk {
    convenience init(dto: _Talk) {

        var delayed = false
        if let del = dto.delayed, del { delayed = del }
        
        self.init(id: dto.id,
        name: dto.name,
        timestamp: dto.date,
        date:  Date(timeIntervalSince1970: TimeInterval(dto.date ?? 0)),
        speakerName: dto.speakerName,
        twitterId: dto.twitterId,
        desc: dto.desc,
        roomName: dto.roomName,
        delayed: delayed,
        photo: dto.photo)
    }
    
    var dto: _Talk {
        get {
            var _talk = _Talk()
            _talk.id = id
            _talk.name = name
            _talk.date = timestamp
            _talk.speakerName = speakerName
            _talk.twitterId = twitterId
            _talk.roomName = roomName
            _talk.desc = desc
            _talk.photo = photo
            _talk.delayed = delayed
            return _talk;
        }
    }
}

extension Config {
    convenience init(dto: _Config) {
        
        self.init(id: dto.id,
                  endTime: Date(timeIntervalSince1970: TimeInterval(dto.endTime ?? 0)),
                  eventDate: Date(timeIntervalSince1970: TimeInterval(dto.eventDate ?? 0)),
                  interval: dto.interval ?? 1800,
                  startTime: Date(timeIntervalSince1970: TimeInterval(dto.startTime ?? 0)),
                  rooms: dto.rooms?.map { Room(dto: $0)} ?? [],
                  breaks: dto.breaks?.map{ Break(dto: $0) } ?? [])
    }
}


extension Room {
    convenience init(dto: _Room) {
        self.init(id: dto.id, name: dto.name)
    }
}

extension Break {
    convenience init(dto: _Break) {
        self.init(id: dto.id, duration: dto.duration ?? 0, time: Date(timeIntervalSince1970: TimeInterval(dto.time ?? 0)))
    }
}

struct _Config: FirebaseMappble {
    var id: String!
    var endTime: Int?
    var eventDate: Int?
    var interval: Int?
    var startTime: Int?
    var rooms: [_Room]?
    var breaks: [_Break]?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        endTime <- map["endTime"]
        eventDate <- map["eventDate"]
        interval <- map["interval"]
        startTime <- map["startTime"]
        rooms <- (map["rooms"], FBArrayTransform<_Room>())
        breaks <- (map["breaks"], FBArrayTransform<_Break>())
    }
    
}

struct _Break: FirebaseMappble  {
    var id: String!
    var duration: Int?
    var time: Int?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        duration <- map["duration"]
        time <- map["time"]
    }
}

struct _Room: FirebaseMappble {
    var id: String!
    var name: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        name <- map["name"]
    }
}


protocol FirebaseMappble: Mappable {
    var id: String! { get set }
}

class FBArrayTransform<T:FirebaseMappble>: TransformType {
    public typealias Object = [T]
    public typealias JSON = [String: Any]
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> [T]? {
        
        if let value = value as? [String: JSON] {
            return value.map({ (key: String, value: JSON) -> T in
                var obj = Mapper<T>().map(JSON: value)!
                obj.id = key
                return obj
            })
        }
        
        return nil
    }
    func transformToJSON(_ value: Object?) -> JSON? {
        if let value = value {
            var Json = [String: Any]()
            value.forEach { Json[$0.id] = $0.toJSON() }
            return Json
            
        }
        
        return nil
    }
    
    

}


