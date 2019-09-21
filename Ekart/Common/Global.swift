//
//  Global.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import Foundation
import UIKit

/// List of api end points
enum Endpoint: String {
    case headyProducts = "/json​"
}

/// Response enum with message
enum ResponseWithMessage: String {
    case badResponse = "Something went wrong"
    case networkIssue = "You are offline"
    case serverIssue = "Unable to reach server"
    case success = "Yay!"
}

struct Global {
    //MARK: - API Constants
    struct api {
        static let headyProducts = "https://stark-spire-93433.herokuapp.com/json"
        static let requestTimeOut = 5.0
    }
    
    //MARK: -  Show Log only when DEBUG
    static func log(_ object: Any) {
        #if DEBUG
        debugPrint(object)
        #endif
    }
    
    /// Font size
    struct fontSize {
        static let big = 17.0
        static let medium = 15.0
        static let small = 13.0
    }
}

//MARK: - Theme Colors
extension UIColor {
    static let headyGray = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1)
    static let headyLightGray = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 0.1)
    static let headyWhite = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    static let headyBlue = UIColor(red: 0/255, green: 106/255, blue: 232/255, alpha: 1)
    static let headyWarningBlack = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
    static let headyText = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1)
}

//MARK: -  Notification Name
extension Notification.Name {
    static let categoriesStartRefresh = Notification.Name("heady.notification.categoriesStartRefresh")
    static let categoriesDidUpdate = Notification.Name("heady.notification.categoriesDidUpdate")
    static let categoriesDidFailToRefresh = Notification.Name("heady.notification.categoriesDidFailToRefresh")
}
