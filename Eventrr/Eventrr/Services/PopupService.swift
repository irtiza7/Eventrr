//
//  AlertService.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import Foundation
import UIKit

/// A service struct that provides various pop-up alert functionalities,
/// such as displaying success, failure, and loading pop-ups, as well as confirmation pop-ups with customizable actions.
struct PopupService {
    
    // MARK: - Static Properties
    
    /// Displays a failure alert with a customizable title and message.
    /// - Parameters:
    ///   - title: The title of the alert. Defaults to the error title defined in `K.StringMessages`.
    ///   - message: The message to be displayed in the alert.
    ///   - presentHandler: A closure that handles the presentation of the alert controller.
    static func displayFailure(
        title: String = K.StringMessages.errorTitle,
        message: String,
        presentHandler: (UIViewController) -> ()) {
            
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertVC.view.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
            alertVC.view.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
            alertVC.view.tintColor = UIColor(named: K.ColorConstants.AccentRed.rawValue)
            
            let alertAction: UIAlertAction = UIAlertAction(
                title: K.StringMessages.errorPopupActionButtonTitle,
                style: .default
            )
            alertVC.addAction(alertAction)
            presentHandler(alertVC)
        }
    
    /// Displays a success alert with a customizable title and message.
    /// - Parameters:
    ///   - title: The title of the alert. Defaults to the success title defined in `K.StringMessages`.
    ///   - message: The message to be displayed in the alert.
    ///   - presentHandler: A closure that handles the presentation of the alert controller.
    static func displaySuccess(
        title: String = K.StringMessages.successTitle,
        message: String,
        presentHandler: (UIViewController) -> ()) {
            
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertVC.view.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
            alertVC.view.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
            alertVC.view.tintColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)
            
            let alertAction: UIAlertAction = UIAlertAction(
                title: K.StringMessages.successPopActionButtonTitle,
                style: .default
            )
            alertVC.addAction(alertAction)
            presentHandler(alertVC)
        }
    
    /// Creates and returns a loading popup with an activity indicator.
    /// - Returns: An `UIAlertController` instance configured as a loading popup.
    static func loadingPopup() -> UIAlertController {
        let alertVC = UIAlertController(title: " ", message: " ", preferredStyle: .alert)
        alertVC.view.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        alertVC.view.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
        alertVC.view.tintColor = UIColor(named: K.ColorConstants.AccentRed.rawValue)
        
        let indicator = UIActivityIndicatorView(frame: alertVC.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        indicator.color = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)
        
        alertVC.view.addSubview(indicator)
        return alertVC
    }
    
    /// Creates and returns a confirmation popup with customizable actions and action titles.
    /// - Parameters:
    ///   - title: The title of the popup. Defaults to nil.
    ///   - message: The message to be displayed in the popup. Defaults to nil.
    ///   - popupStyle: The style of the popup (e.g., action sheet or alert).
    ///   - actionTitles: An array of titles for the actions.
    ///   - actionStyles: An array of styles for the actions (e.g., default, cancel, destructive).
    ///   - actionHandlers: An array of closures to handle each action's selection.
    /// - Returns: An `UIAlertController` instance configured as a confirmation popup.
    static func confirmationPopup(
        title: String? = nil,
        message: String? = nil,
        popupStyle: UIAlertController.Style,
        actionTitles: [String],
        actionStyles: [UIAlertAction.Style],
        actionHandlers: [(UIAlertController) -> ()]) -> UIAlertController {
            
            assert(actionTitles.count == actionStyles.count)
            
            let popup = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            popup.view.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
            popup.view.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
            popup.view.tintColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)
            
            for i in 0 ..< actionTitles.count {
                let action = UIAlertAction(title: actionTitles[i], style: actionStyles[i]) { _ in
                    actionHandlers[i](popup)
                }
                popup.addAction(action)
            }
            return popup
        }
}
