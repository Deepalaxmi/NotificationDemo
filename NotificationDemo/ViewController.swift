//
//  ViewController.swift
//  NotificationDemo
//
//  Created by Kh. Deepalaxmi on 13/09/18.
//  Copyright © 2018 Kh. Deepalaxmi. All rights reserved.
//

import UIKit
import UserNotifications

struct common {
    static let identifier = "notificationDemo.local"
    static let identifierBackgroundFetch = "notificationDemo.localBackground"

}

class ViewController: UIViewController {
    let center = UNUserNotificationCenter.current()

    @IBOutlet weak var welcomeLabel: UILabel!
    
    private var time: Date?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateUI()
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            print("\(requests.count) pending requests -------")
            for request in requests{
                print(request.identifier)
                print(request.trigger ?? "empty")
                if let t = request.trigger as? UNCalendarNotificationTrigger{
                    print("UNCalendarNotificationTrigger")
                    print(t.dateComponents)
                    print(t.nextTriggerDate() ?? "empty next trigger date")
                    print(t.dateComponents.date ?? "no date")

                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        
        if let time = time {
            welcomeLabel.text = dateFormatter.string(from: time)
        } else {
            welcomeLabel.text = "Not yet updated"
        }
    }
    
    func fetch(completion: ()-> Void){
        time = Date()
        fireLocalNotification(time: time ?? Date())
        completion()
    }

    @IBAction func setNotificationBtnTapped(_ sender: UIButton) {
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            guard setting.authorizationStatus == .authorized else {
                return
            }
            
            //content
            let content = UNMutableNotificationContent()
            content.title = "Local Reminder"
            content.subtitle = "This is a reminder"
            content.body = "Mark your attendance as soon as possible otherwise 😬 💣 🔪 🔫 3"
            content.sound = UNNotificationSound.default()
            content.badge = 1
            content.launchImageName = "👍🏻"
            
            
            //trigger
            //time interval
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            //calendar particular date time
            let date = Date(timeIntervalSinceNow: 10)
//            print(date)
//            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
//                                                        repeats: false)
//
            //trigger daily
            let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
            //identifier
//            let uuid = UUID().uuidString
//            print(uuid)

            // remove previously scheduled notifications
//            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [uuid])
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid])
            self.center.removeAllPendingNotificationRequests()
            //request
            let request = UNNotificationRequest(identifier: common.identifier, content: content, trigger: trigger)
            self.center.add(request) {
                (error) in
                if let error = error
                {
                    print(error.localizedDescription)
                }
                print("completion")
            }
        }
    }
    
    @IBAction func removeNotificationBtnTapped(_ sender: UIButton) {
        // remove previously scheduled notifications
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [common.identifier])
        center.removePendingNotificationRequests(withIdentifiers: [common.identifier])
        center.removeAllPendingNotificationRequests()

    }
    
    func fireLocalNotification(time: Date){
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            guard setting.authorizationStatus == .authorized else {
                return
            }
            
            //calendar particular date time
            let date = time.addingTimeInterval(10)
            print("fireLocalNotification --- \(date)")

            
            //content
            let content = UNMutableNotificationContent()
            content.title = "Background Local Reminder"
            content.subtitle = "This is a background reminder"
            content.body = "Background fetch time \(time), notification will fire after 10s \(date) "
            content.sound = UNNotificationSound.default()
            content.badge = 2
            content.launchImageName = "👍🏻"
            
            
            //trigger daily
            let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
            
            self.center.removeAllPendingNotificationRequests()
            //request
            let request = UNNotificationRequest(identifier: common.identifierBackgroundFetch, content: content, trigger: trigger)
            self.center.add(request) {
                (error) in
                if let error = error
                {
                    print(error.localizedDescription)
                }
                print("completion background")
            }
        }
    }
}



