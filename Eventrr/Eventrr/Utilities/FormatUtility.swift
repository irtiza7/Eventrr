//
//  FormatUtility.swift
//  Eventrr
//
//  Created by Dev on 8/22/24.
//

import Foundation

struct FormatUtility {
    static func formatDateAndTime(
        dateString: String,
        fromTimeString: String,
        toTimeString: String) -> (dateFormatted: String, timeFormatted: String) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            guard let date = dateFormatter.date(from: dateString),
                  let fromTime = dateFormatter.date(from: fromTimeString),
                  let toTime = dateFormatter.date(from: toTimeString) else {
                return ("Invalid Date", "Invalid Time")
            }
            
            dateFormatter.dateFormat = "E d MMM yyyy"
            let dateFormatted = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "h:mm a"
            let fromTimeFormatted = dateFormatter.string(from: fromTime)
            let toTimeFormatted = dateFormatter.string(from: toTime)
            let timeFormatted = "\(fromTimeFormatted) - \(toTimeFormatted)"
            
            return (dateFormatted, timeFormatted)
        }
    
    static func convertStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return dateFormatter.date(from: dateString)
    }
    
    static func convertStringToTime(timeString: String) -> Date? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.date(from: timeString)
    }
    
    static func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    static func convertStringToDateUTC(dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }
}
