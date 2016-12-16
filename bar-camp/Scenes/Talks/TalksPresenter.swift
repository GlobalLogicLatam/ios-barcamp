//
//  TalksPresenter.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/30/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit

protocol TalksPresenterInput {
    
    /// Prepare view model with provided talk times
    ///
    func presentTalkTimes(response: TalkTimesRP)

    /// Prepare view model with admin validation
    ///
    /// - parameter isAdmin: The admin validation result
    func presentAdmin(_ isAdmin: Bool)
    
    /// Prepare view model when a talk is created
    func presentTalkCreated()
    
    /// Prepare view model with provided parameters
    ///
    /// - parameter image: The image
    /// - parameter url:   The url
    func presentTalkImage(_ image: UIImage, url: String)
    
    /// Prepare view model on delayed status changes
    func presentDelayed()
    
    /// Prepare view model for error messages
    ///
    /// - parameter msg: The error description
    func presentError(msg: String)
    
    /// Prepare the view model for logs out
    func presentLogOut()
    
    /// Prepare view model for internet conecction changes
    ///
    /// - parameter available: The internet availability
    func presentInternet(available: Bool)
    
    
    /// Prepare view model with provided data
    ///
    /// - parameter config: The config model
    func presentConfig(_ config: Config)
    
}

protocol TalksPresenterOutput: class {
    func displayTalkTimes(viewModel: TalksVM)
    func displayAdmin(_ isAdmin: Bool)
    func displayTalkCreated()
    func displayTalkImage(_ image: UIImage, url: String)
    func displayDelayed()
    func displayError(msg: String)
    func displayLogOut()
    func displayInternet(available: Bool)
    func displayConfig(_ config: ConfigVM)
    
}

class TalksPresenter: TalksPresenterInput {
    weak var output: TalksPresenterOutput!
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.init(abbreviation: "GMT")
        return formatter
    }()
    
    var hourFormatter: DateFormatter {
         let ft = formatter
        ft.dateFormat = "HH:mm 'hs'"
        return ft
    }

    var dateFormatter: DateFormatter {
        let ft = formatter
        ft.dateFormat = NSLocalizedString("talk_start_date_format", comment: "")
        
        return ft
    }
    
    
    // MARK: Presentation logic

    func presentTalkTimes(response: TalkTimesRP){
        // NOTE: Format the response from the Interactor and pass the result back to the View Controller

        let config = response.config
        
        var times = [Int: TalkListSection]()
        
        //Creates the time slots
        //All times slots are in unix time format
        for i in 0...config.timeSlots() {
            
            //First time slot starts on the start time
            let time = Int(config.startTime.timeIntervalSince1970)+i*config.interval
            //Format the slot time as string
            let str = self.hourFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
            //Asks for time slot break status
            let isBreak = config.isBreakSlot(time)
            //Creates a section based on time slot
            let section = TalkListSection(dateString: str, timestamp: time, isBreak: isBreak, talks: [TalkVM]())
            times[time] = section
        }
        
        //Iterates over all talks and populates the seccion objects.
        for talk in response.talks {
            if let ts = talk.timestamp, var section = times[ts] {
                
                
                
                let tvm = TalkVM(id: talk.id,
                                 name: talk.name ?? "",
                                 timestamp: ts,
                                 speakerName: talk.speakerName ?? "",
                                 twitterId: talk.twitterId ?? "",
                                 roomName: talk.roomName ?? "",
                                 desc: talk.desc == nil || talk.desc!.isEmpty ? NSLocalizedString("talk_without_description", comment: "") : talk.desc!,
                                 delayed: talk.delayed,
                                 photo: talk.photo)
                section.talks.append(tvm)
                times[ts] = section
            }
        }
        
        //Generating sorted array
        //https://bugs.swift.org/browse/SR-2977
        //let array = times.values.sorted { $0.timestamp < $1.timestamp}
        
        //We are avoinding use the sorted function because it generates compiling error 
        //when project archives
        var array = [TalkListSection]()
        for i in 0...config.timeSlots() {
            let time = Int(config.startTime.timeIntervalSince1970)+i*config.interval //8:00 AM start time
            array.append(times[time]!)
        }
        
        let viewModel = TalksVM(array)
        
        output.displayTalkTimes(viewModel: viewModel)
    }
    func presentAdmin(_ isAdmin: Bool) {
        self.output.displayAdmin(isAdmin)
    }
    
    func presentTalkCreated() {
        self.output.displayTalkCreated()
    }
    
    func presentError(msg: String) {
        self.output.displayError(msg: msg)
    }
    
    func presentLogOut() {
        self.output.displayLogOut()
    }
    
    func presentTalkImage(_ image: UIImage, url: String) {
        self.output.displayTalkImage(image, url: url)
    }
    
    func presentDelayed() {
        self.output.displayDelayed()
    }
    
    func presentInternet(available: Bool) {
        self.output.displayInternet(available: available)
    }
    
    func presentConfig(_ config: Config) {
        let rooms = config.rooms.map{ $0.name ?? "" }
        
        let dateString = self.dateFormatter.string(from: config.eventDate);        
        let vm = ConfigVM(rooms: rooms, startDate: config.eventDate, startDateString: dateString)
        self.output.displayConfig(vm)
    }



}
