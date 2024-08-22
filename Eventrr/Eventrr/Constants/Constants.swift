//
//  Constants.swift
//  Eventrr
//
//  Created by Dev on 8/6/24.
//

import Foundation

struct K {
    enum ColorConstants: String {
        case WhitePrimary, BlackPrimary, AccentPrimary, AccentSecondary, AccentTertiary, AccentRed, AccentOrange
    }
    
    struct StringMessages {
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        static let errorTitle = "Error"
        static let successTitle = "Success"
        static let loginFailurePopupTitle = "Login Failed"
        static let signupFailurePopupTitle = "Signup Failed"
        
        static let requiredFieldString = "Required"
        static let somethingWentWrong = "Something went wrong. Please try again later."
        static let enterValidEmailErrorString = "Please enter a valid email"
        static let passwordLengthErrorString = "Password should be of length 8"
        static let passwordsMismatchErrorString = "Passwords do not match"
        
        static let emailSentForPasswordReset = "Email sent with the link to reset password."
        static let pleaseSelectAValidLocation = "Please select a valid location."
        static let locationPermissionError = "Couldn't fetch location because the user has not given permission"
        static let currentLocationFetchError = "Could't fetch current location."
        static let eventsFetchError = "Couldn't fetch events, try later."
        
        static let fieldMustContainSomeText = "Field must contain some text."
        static let startTimeOneHourAfterCurrentTime = "Start time must at least be 1 hour from now."
        static let endTimeBeforeDayEndTime = "End time must be before 11:59 PM."
        static let startTimeMustPrecedeEndTime = "Start time must be before end time."
        
        static let eventDeletionConfirmationMessage = "Are you sure you want to delete this event?"
        static let eventLeaveConfirmationMessage = "Are your sure you want to leave this event?"
        static let eventJoinConfirmationMessage = "Are your sure you want to join this event?"
        
        static let errorPopupActionButtonTitle = "Retry"
        static let successPopActionButtonTitle = "Okay"
    }
    
    struct MainStoryboardIdentifiers {
        static let mainBundle = "Main"
        static let authNavigationController = "AuthNavigationController"
    }
    
    struct EventsStoryboardIdentifiers {
        static let eventsBundle = "Events"
        static let mainTabViewController = "MainTabViewController"
        static let createEventNavigationController = "CreateEventNavigationController"
        
        static let eventCell = "EventCell"
        static let locationSuggestionCell = "LocationSuggestionCell"
    }

    struct UI {
        static let defaultPrimaryCornerRadius: CGFloat = 12
        static let defaultSecondardCornerRadius: CGFloat = 8
        static let defaultTertiaryCornerRadius: CGFloat = 4
        
        static let defaultPrimaryBorderWidth: CGFloat = 1
        static let defaultSecondaryBorderWidth: CGFloat = 0.7
    }
    
    struct ButtonAndPopupActionTitle {
        static let create = "Create"
        static let update = "Update"
        static let delete = "Delete"
        static let cancel = "Cancel"
        static let leave = "Leave"
        static let join = "Join"
        static let edit = "Edit"
        static let saveAsDraft = "Save as Draft"
        static let continueEditing = "Continue Editing"
        static let discard = "Discard"
    }
}
