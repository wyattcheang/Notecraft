//
//  Extension.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 18/07/2024.
//

import Foundation
import UIKit
import SwiftUI

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
                
        return regex.firstMatch(in: self, range: NSRange(location: 0, length: count)) != nil
    }
    
    func isValidPassword() -> Bool {
        // minimum 6 characters long
        // 1 uppercase character
        // 1 special char
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[$@$#!%*?&]).{6,}$")
        return passwordRegex.evaluate(with: self)
    }
}

extension Int {
    func secondToString() -> String {
        let hour = self / 3600
        let minute = (self % 3600) / 60
        let second = self % 60
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension UIApplication {
    var rootViewController: UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("There is no root view controller")
            return nil
        }
        return window.rootViewController
    }
}

