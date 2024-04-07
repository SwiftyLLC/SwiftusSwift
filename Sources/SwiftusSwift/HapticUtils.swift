//
//  HapticUtils.swift
//

import Foundation
import UIKit

public class HapticUtils {
    
    /// UINotificationFeedbackGenerator  SUCCESS - 2 time tic
    public class func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// UINotificationFeedbackGenerator  WARNING
    public class func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// UINotificationFeedbackGenerator  ERROR
    public class func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // 1 tic with impact
    /// UIImpactFeedbackGenerator  LIGHT
    public class func light() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
    /// UIImpactFeedbackGenerator  MEDIUM
    public class func medium() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
    /// UIImpactFeedbackGenerator  HEAVY
    public class func heavy() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
    /// UISelectionFeedbackGenerator  SELECTION ITEM
    public class func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
