//
//  NotificationService.swift
//  Eventrr
//
//  Created by Irtiza on 8/28/24.
//

import Foundation
import UserNotifications
import FirebaseAuth

/// A singleton service class that manages the scheduling and cancellation of event notifications.
/// It also handles the user's authentication state and requests notification permissions from the system.
///
/// > Important: Requires permission from the user to show notifications.
final class NotificationService {
    
    static var shared: NotificationService?
    
    /// Creates a shared singleton instance of Notification Service.
    static func createInstance() {
        if NotificationService.shared == nil {
            NotificationService.shared = NotificationService()
        }
    }
    
    // MARK: - Private Properties
    
    /// Stores a reference to the observer of user's autheentication (Firebase Auth) state.
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    // MARK: - Initializers and Deinitializers
    
    private init() {
        requestNotificationPermission()
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Private Methods
    
    /// Cancels all the scheduled notifications.
    /// Can be called once the user sign outs of the app.
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Requests permission from the system, to show event notifications to the user.
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let _ = error {
                NotificationService.shared = nil
            }
        }
    }
    
    /// Setups a listener to the user's authentication (Firebase Auth) state. Cancels all the scheduled notifications, once the user is signed out.
    private func setupAuthStateListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if user == nil {
                self?.cancelAllNotifications()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Schedules a notification 1 hour before the  starting time of given event.
    ///
    /// Can be called when the user joins an event.
    /// - Parameters:
    ///   - eventId: Id of event for which notification is to be set.
    ///   - eventTitle: Title of event for which notification is to be set. This title is also shown in the notification.
    ///   - fromTime: Starting time of event, and the notification is set 1 hour before this time.
    public func scheduleEventNotification(eventId: String, eventTitle: String, fromTime: String) {
        guard let eventDate = FormatUtility.convertStringToDateUTC(dateString: fromTime) else { return }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = "[\(eventTitle)] starts in 1 hour."
        content.sound = UNNotificationSound.default
        
        guard let triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: eventDate) else { return }
        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        
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
    
    /// Deletes a notification of provided event.
    ///
    /// Should be called once the user leaves a joined event.
    /// - Parameter eventId: Id of event for which the notification should be deleted.
    public func cancelEventNotification(eventId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventId])
    }
}
