//
//  ViewController.swift
//  EventKitDemo
//
//  Created by soc-macmini-45 on 17/08/17.
//  Copyright © 2017 soc-macmini-45. All rights reserved.
//
import UIKit
import  EventKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var allEvents = [EKEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventKitHelper.shared = EventKitHelper() // for initializing calendar and asking permissions (required)
        EventKitHelper.shared?.calendarName = "New Calendar" //if u want to give a name to the calendar else (My new calendar by default)
    }
    
    @IBAction func fetchAllEvvars(_ sender: Any) {
        allEvents =  (EventKitHelper.shared?.getEventsFromCalenderWith(identifier: (EventKitHelper.shared?.calendarName)!, startingTimeInterval: -30*24*3600, endingTimeInterval: +30*24*3600))!
        tableView.reloadData()
    }
    
    
    @IBAction func eventACtion(_ sender: Any) {
    //   -------This is how you add event in calendar using the Event helper---------
        
        
        let event = CalendarEvent(title: "lets see", startDate: "2017-08-12T18:10:52.000Z", endDate: "2017-08-13T15:10:52.000Z", description: "Notes added")
        
        EventKitHelper.shared?.addAppleEvents(calenderEvent: event, callback: { (result) in
            switch result {
            case .success(let event):
                print(event.title)
                NSLog("event.title\(event.title)")
            case .error(let error):
                print(error)
            }
        })
    }
    
    @IBAction func clearAction(_ sender: UIButton) {
        allEvents.removeAll()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        cell.nameLabel.text = allEvents[indexPath.row].title
        cell.date.text = "\(allEvents[indexPath.row].startDate)"
        return cell
    }
}

class Cell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}


