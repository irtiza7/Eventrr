//
//  AlertService.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import Foundation
import UIKit

struct Popups {
    
    // MARK: - Static Properties
    
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
