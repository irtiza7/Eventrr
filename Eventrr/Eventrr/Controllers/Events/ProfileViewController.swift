//
//  ProfileViewController.swift
//  Eventrr
//
//  Created by Dev on 8/21/24.
//

import UIKit
import SwiftUI

class ProfileViewController: UIViewController {
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileView = UserProfileView()
            .environment(\.navigationController, navigationController)
        
        let hostingController = UIHostingController(rootView: profileView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
