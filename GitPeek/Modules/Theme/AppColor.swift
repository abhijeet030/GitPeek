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
            : UIColor(hex: "#F3F0FF")
    }

    static var primary: UIColor {
        return UIColor(hex: "#9A6EF5")
    }

    static var accent: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#C2A8FF")
            : UIColor(hex: "#7E51E8")
    }

    static var textPrimary: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(hex: "#2B0E5C")
    }

    static var textSecondary: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#BBBBBB")
            : UIColor(hex: "#6C4BB5")
    }

    static var cardBackground: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#1E1E1E")
            : UIColor(hex: "#EFE8FF")
    }

    static var tableBackground: UIColor {
        return background
    }

    static var tableSeparator: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#333333")
            : UIColor(hex: "#D3C4F2")
    }

    static var tableSelectedCell: UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor(hex: "#2A2A2A")
            : UIColor(hex: "#E1D5FF")
    }
}
