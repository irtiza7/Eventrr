//
//  NotificationService.swift
//  Eventrr
//
//  Created by Irtiza on 8/28/24.
//

import Foundation
import UserNotifications
import FirebaseAuth

class NotificationService {
    
    static var shared: NotificationService?
    
    static func createInstance() {
        if NotificationService.shared == nil {
            NotificationService.shared = NotificationService()
        }
    }
    
    // MARK: - Private Properties
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Initializers
    
    private init() {
        requestNotificationPermission()
        setupAuthStateListener()
    }
    
    // MARK: - Deinitialzers
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Private Methods
    
    /*
     Will be called when the user logs out of the app.
     */
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let _ = error {
                NotificationService.shared = nil
            }
        }
    }
    
    /*
     Method will listen to the authentication state and will remove all the added notifications
     once the user has been logged out.
     */
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if user == nil {
                self?.cancelAllNotifications()
            }
        }
    }
    
    // MARK: - Public Methods
    
    public func scheduleEventNotification(eventId: String, eventTitle: String, fromTime: String) {
        guard let eventDate = FormatUtility.convertStringToDateUTC(dateString: fromTime) else { return }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = "[\(eventTitle)] starts in 1 hour."
        content.sound = UNNotificationSound.default
        
        guard let triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: eventDate) else { return }
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        
        let trigger: UNCalendarNotificationTrigger
        
        /*
         iOS requires only hours and minutes if the date is same as today
         otherwise the notifications aren't triggered.
         */
        if Calendar.current.isDateInToday(eventDate) {
            trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.hour, .minute], from: triggerDate),
                repeats: false
            )
        } else {
            trigger = UNCalendarNotificationTrigger(
                dateMatching: triggerComponents,
                repeats: false
            )
        }
        
        let request = UNNotificationRequest(identifier: eventId, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    /*
     Will be called once the user leaves an event.
     */
    func cancelEventNotification(eventId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventId])
    }
}
