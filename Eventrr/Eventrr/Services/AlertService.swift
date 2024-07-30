//
//  AlertService.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import Foundation
import UIKit

final class AlertService {
    
    // MARK: - Static Properties
    
    static let shared = AlertService()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Properties
    
    @MainActor
    public func showFailureAlert(title: String = "Error", message: String, view: UIViewController) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertVC.view.layer.cornerRadius = 12
        alertVC.view.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
        alertVC.view.tintColor = UIColor(named: K.ColorConstants.AccentRed.rawValue)
        
        let alertAction: UIAlertAction = UIAlertAction(title: K.AuthConstants.errorPopupActionButtonTitle, style: .default)
        alertVC.addAction(alertAction)
        
        view.present(alertVC, animated: true)
    }
    
    public func getLoadingAlertViewController() -> UIAlertController {
        let alertVC = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView(frame: alertVC.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        indicator.color = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)
        
        alertVC.view.addSubview(indicator)
        alertVC.view.layer.cornerRadius = 12
        alertVC.view.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
        alertVC.view.tintColor = UIColor(named: K.ColorConstants.AccentRed.rawValue)
        
        return alertVC
    }
    
    public func showFieldValidationFailureAlert(title: String = "Error", message: String, present: @escaping (UIViewController) -> ()) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.view.layer.cornerRadius = 12
        alertVC.view.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
        alertVC.view.tintColor = UIColor(named: K.ColorConstants.AccentRed.rawValue)
        
        let alertAction: UIAlertAction = UIAlertAction(title: K.AuthConstants.errorPopupActionButtonTitle, style: .default)
        alertVC.addAction(alertAction)
        
        present(alertVC)
    }
    
    public func showSuccessAlert(title: String = "Success", message: String, present: (UIViewController) -> ()) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.view.layer.cornerRadius = 12
        alertVC.view.backgroundColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
        alertVC.view.tintColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)
        
        let alertAction: UIAlertAction = UIAlertAction(title: K.AuthConstants.successPopActionButtonTitle, style: .default)
        alertVC.addAction(alertAction)
        
        present(alertVC)
    }
}
