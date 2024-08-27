//
//  EnvironmentValues+Extension.swift
//  Eventrr
//
//  Created by Dev on 8/22/24.
//

import Foundation
import SwiftUI

struct NavigationControllerKey: EnvironmentKey {
    static let defaultValue: UINavigationController? = nil
}

extension EnvironmentValues {
    var navigationController: UINavigationController? {
        get { self[NavigationControllerKey.self] }
        set { self[NavigationControllerKey.self] = newValue }
    }
}
