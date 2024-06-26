//
//  SwiftusUtils.swift
//
//
//  Created by SwiftusSwift on 07/04/2024.
//

import UIKit
import SwiftUI
import AppTrackingTransparency
import AdSupport

public class SwiftusUtils {
    
    public static func requestATTracking(_ complete: ((_ status: ATTrackingManager.AuthorizationStatus) -> Void)?) {
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          if let action = complete {
              action(status)
          }
      })
    }

    public static func openURL(_ url: String) {
        guard let urlOpen = URL(string: url) else { return }
        UIApplication.shared.open(urlOpen)
    }
    
    public static func shareItems(_ items: [Any]) {
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
              print("UNABLE TO GET CURRENT SCENE")
              return
        }
        activityController.popoverPresentationController?.sourceView = currentScene.windows.first?.rootViewController?.view
        activityController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)

        currentScene.windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
    }
    
    public static func durationTime(seconds: Float) -> String {
        if seconds.isNaN || seconds <= 0.1 {
            return ""
        }
        let totalSeconds: Float = ceil(seconds)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let second = Int(totalSeconds.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, second)
        } else {
            return String(format: "%02i:%02i", minutes, second)
        }

    }
    
    public static func durationTimeRecording(seconds: Float) -> String {
        if seconds.isNaN {
            return ""
        }
        let totalSeconds: Float = ceil(seconds)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let second = Int(totalSeconds.truncatingRemainder(dividingBy: 60))

        return String(format: "%02i:%02i:%02i", hours, minutes, second)
    }
    
//    static func mailFeebackBody() -> String {
//        let version: String = SwiftusUtils.appVersion()
//        let appName: String = SwiftusUtils.appName()
//        return "\n\n\n\n\n\n\(appName), Version \(version)\nModel: \(UIDevice.current.modelName) (\(UIDevice.current.systemVersion))"
//    }
    
    /// Read plist info mation
    public static func plistInfo() -> [String: Any] {
        var config: [String: Any]?
                
        if let infoPlistPath = Bundle.main.url(forResource: "Info", withExtension: "plist") {
            do {
                let infoPlistData = try Data(contentsOf: infoPlistPath)
                
                if let dict = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                    config = dict
                }
            } catch {
                print(error)
            }
        }
        return config ?? [:]
    }
    
    /// version 1.0
    public static func appVersion() -> String {
        let config : [String: Any] = SwiftusUtils.plistInfo()
        let value: String? = config["CFBundleShortVersionString"] as? String
        return value ?? ""
    }
    
    ///app name: IDPasport
    public static func appName() -> String {
        let config : [String: Any] = SwiftusUtils.plistInfo()
        let value: String? = config["CFBundleDisplayName"] as? String
        return value ?? ""
    }
    
    ///com.ORL Products....
    public static func appBundleName() -> String {
        let config : [String: Any] = SwiftusUtils.plistInfo()
        let value: String? = config["CFBundleName"] as? String
        return value ?? ""
    }
    
    /// build 1
    public static func appBundleVersion() -> String {
        let config : [String: Any] = SwiftusUtils.plistInfo()
        let value: String? = config["CFBundleVersion"] as? String
        return value ?? ""
    }
    
//    ///Device model: iPhone 5S (16.1)
//    public static func deviceName() -> String {
//        var device = ""
//        
//        return device
//    }
//    
//    ///OS version: 16.1
//    public static func osVersion() -> String {
//        var version = ""
//        
//        return version
//    }
    
    public static func isPhone() -> Bool {
        print(UIDevice.current.userInterfaceIdiom)
        if UIDevice.current.userInterfaceIdiom == .phone {
           print("running on iPhone")
            return true
        }
        return false
    }
    
    public static func isRunInPreview() -> Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    public static func countryLocalFlag(_ local: Locale?) -> String {
        guard let obj = local else {
            return ""
        }
        let countryCode = obj.identifier.split(separator: "-").last ?? ""
        debugPrint(countryCode)
        return String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap {
            UnicodeScalar(127397 + $0.value)
        }))
    }
    
    
    public static func countryFlag(_ countryCode: String) -> String {
        debugPrint(countryCode)
        return String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap {
            UnicodeScalar(127397 + $0.value)
        }))
    }
}


public func delay(_ delay: Double, block: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        block()
    }
}
