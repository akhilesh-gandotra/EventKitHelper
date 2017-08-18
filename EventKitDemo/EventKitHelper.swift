//
//  EventHelper.swift
//
//  Created by Akhilesh on 28/07/17.
//  Copyright © 2017 Akhilesh Gandotra. All rights reserved.
//

import Foundation
import EventKit
import UIKit

struct CalendarEvent {
    let title: String
    let startDate: String
    let endDate: String
    let description: String?
}
enum CalendarResult {
    case success(CalendarEvent)
    case error(Error)
}

class EventKitHelper {
    
    //MARK: Variables
    static var shared: EventKitHelper?
    let appleEventStore = EKEventStore()
    private var isPermissionGranted = false  //for checking permission
    public var calendarName = "My New Calendar"
  
    //MARK: For initializing the calendar
    func generateEvent() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch (status)
        {  
        case EKAuthorizationStatus.notDetermined:  // This happens on first-run
            requestAccessToCalendar()
            
        case EKAuthorizationStatus.authorized:
            self.isPermissionGranted = true
            
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            self.isPermissionGranted = false
            print("User has to change settings...goto settings to view access")
        }
    }
    
    init() {
        generateEvent()
    }
    
    
    
    //MARK: For fetching events from a particular calendar
    public func getEventsFromCalenderWith(identifier: String, startingTimeInterval: TimeInterval, endingTimeInterval: TimeInterval) -> [EKEvent] {
        let calendars = appleEventStore.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == identifier {
            
                let startingTime = Date(timeIntervalSinceNow: startingTimeInterval)
                let endingTime = Date(timeIntervalSinceNow: endingTimeInterval)
                
                let predicate = appleEventStore.predicateForEvents(withStart: startingTime, end: endingTime, calendars: [calendar])
                
                
                let events = appleEventStore.events(matching: predicate)
                var eventArray = [EKEvent]()
                for event in events {
                   eventArray.append(event)
                }
                return eventArray
            }
 
        }
        return [EKEvent]()
    }
    
    //MARK: For checking permission to access calendar
   private func requestAccessToCalendar() {
        appleEventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                    print("User has access to calendar")
                    self.isPermissionGranted = true
                    self.addCalendar(calendarName: self.calendarName)
                
            } else {
                self.isPermissionGranted = false
            }
        })
    }
    
    
    public func addAppleEvents(calenderEvent: CalendarEvent, callback: ((CalendarResult) -> Void)) {
        addCalendar(calendarName: calendarName)
        
        let event:EKEvent = EKEvent(eventStore: appleEventStore)
        event.title = calenderEvent.title
        event.startDate = convertDateFormatter(string: calenderEvent.startDate)
        event.endDate = convertDateFormatter(string: calenderEvent.endDate)
        event.notes = calenderEvent.description
        let calendars = appleEventStore.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == calendarName {
                event.calendar = calendar
            }
        }

        event.addAlarm(EKAlarm(absoluteDate: convertDateFormatter(string: calenderEvent.startDate)))
        
        do {
            try appleEventStore.save(event, span: .thisEvent)
            print("Event Added")
            callback(.success(calenderEvent))
        } catch let error as NSError {
            print(error.description)
            if self.isPermissionGranted {
            callback(.error(error))
            } else {
                let errorTemp = NSError(domain:EKErrorDomain, code: 20, userInfo: ["message":"Permission not granted for calendar"])
                callback(.error(errorTemp))
            }
            
        }
    }
    
    //MARK: For Adding a new calendar into the calendars
   private func addCalendar(calendarName: String) {
    appleEventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
             self.isPermissionGranted = true
            } else {
               self.isPermissionGranted = false
        }
        })
        if !self.isPermissionGranted {
            return
        }
        
        let calendars = appleEventStore.calendars(for: .event)
        for abc in calendars {
            if abc.title == calendarName {
             return
            }
        }
        let eventStore = EKEventStore()
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = calendarName
        let sourcesInEventStore = eventStore.sources
        newCalendar.source = sourcesInEventStore.filter {
            (source: EKSource) -> Bool in
            source.sourceType == EKSourceType.local
            }.first!
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: "EventTrackerPrimaryCalendar")
            print("Calendar is set now")
            
        } catch {
            print(error)
        }
    }
    
    //MARK: String to date convertor
    func convertDateFormatter(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"   //this your string date format
        let date = dateFormatter.date(from: string)

        guard let convertedDate = date else {
            fatalError("date format is wrong")
        }
        return convertedDate
    }
}
