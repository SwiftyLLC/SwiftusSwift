//
//  SwiftusUserdefault.swift
//
//
//  Created by SwiftusSwift on 07/04/2024.
//

import Foundation

fileprivate struct UserDefaultsKeys {
    static let isPremium = "isPremium"
    static let isFirstPreview = "isFirstPreview"
    static let isRequestedIDFA = "isRequestedIDFA"
    static let countAppOpened = "countAppOpened"
}

public extension UserDefaults {

    class var isPremium: Bool {
        get { return standard.bool(forKey: UserDefaultsKeys.isPremium) }
        set { standard.set(newValue, forKey: UserDefaultsKeys.isPremium) }
    }
    
    class var isRequestedIDFA: Bool {
        get { return standard.bool(forKey: UserDefaultsKeys.isRequestedIDFA) }
        set { standard.set(newValue, forKey: UserDefaultsKeys.isRequestedIDFA) }
    }
    
    class var isFirstPreview: Bool {
        get { return standard.bool(forKey: UserDefaultsKeys.isFirstPreview) }
        set { standard.set(newValue, forKey: UserDefaultsKeys.isFirstPreview) }
    }

    class var countAppOpened: Int {
        get { return standard.integer(forKey: UserDefaultsKeys.countAppOpened) }
        set { standard.set(newValue, forKey: UserDefaultsKeys.countAppOpened) }
    }

}
