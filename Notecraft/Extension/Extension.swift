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
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", 
                                             options: .caseInsensitive)
        
        return regex.firstMatch(in: self, range: NSRange(location: 0, length: count)) != nil
    }
    
    func isValidPassword() -> Bool {
        // minimum 6 characters long
        // 1 uppercase character
        // 1 special char
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[$@$#!%*?&]).{6,}$")
        return passwordRegex.evaluate(with: self)
    }
    
    var dropHexPrefix: String {
        return self.replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: "U+", with: "")
            .replacingOccurrences(of: "#", with: "")
    }
    
    var toUnicode: String {
        if let charCode = UInt32(self.dropHexPrefix, radix: 16),
           let unicode = UnicodeScalar(charCode) {
            let str = String(unicode)
            return str
        }
        return "error"
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
    
    var toUnicode: String {
        return String(UnicodeScalar(self)!)
    }

    var ordinal: String {
        let suffix: String
        switch self % 10 {
        case 1 where self % 100 != 11:
            suffix = "st"
        case 2 where self % 100 != 12:
            suffix = "nd"
        case 3 where self % 100 != 13:
            suffix = "rd"
        default:
            suffix = "th"
        }
        return "\(self)\(suffix)"
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

extension UIImage {
    public class func gif(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            print("This image named \"\(name)\" does not exist!")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        return gif(data: imageData)
    }
    
    public class func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("Cannot create image source with data")
            return nil
        }
        return UIImage.animatedImageWithSource(source)
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var duration = 0.0

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
                let delaySeconds = UIImage.delayForImageAtIndex(Int(i), source: source)
                duration += delaySeconds
            }
        }

        if duration == 0.0 {
            duration = 1.0
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        if let delay = delayObject as? Double, delay > 0 {
            return delay
        } else {
            return 0.1
        }
    }
}
