//
//  AppColor.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import UIKit

enum AppColor {
    static var background: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#121212")
            : UIColor.white
    }

    static var primary: UIColor {
        return UIColor(hex: "#895CFF")
    }

    static var accent: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#C2A8FF")
            : UIColor(hex: "#5E3DC6")
    }

    static var textPrimary: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor.black
    }

    static var textSecondary: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#BBBBBB")
            : UIColor(hex: "#555555")
    }

    static var cardBackground: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#1E1E1E")
            : UIColor(hex: "#F9F9F9")
    }
    
    static var tableBackground: UIColor {
        return background
    }

    static var tableSeparator: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#333333")
            : UIColor(hex: "#E5E5E5")
    }

    static var tableSelectedCell: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#2A2A2A")
            : UIColor(hex: "#EEEEEE")
    }
}
