//
//  helper.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 4/10/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Helper {
    
    //    Throw error based on string given, needs to be built out
    static func throwError(error: String) -> UIAlertController {
        var title = String()
        var description = String()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        switch (error)
        {
        case "currency not found":
            title = "Unknown currency"
            description = "You countries currency is not currently supported, please contact me and let me know what currency and country you are trying to use."
        case "no results":
            title = "No results"
            description = "No results for your search could be found. It could be that nothing matches your search or that iTunes is currently experiencing issues and you must try again later."
        case "bad link":
            title = "Link unusable"
            description = "The link you gave was not usable, try copying it again."
        case "thumbnail not found":
            title = "Problem finding thumbnail"
            description = "There was a problem finding your items thumbnail. The iTunes servers are probably overwhelmed. I recommend trying again later."
        case "network problem":
            title = "Network error"
            description = "Something went wrong contacting the network. Either you are not connected to the internet or the iTunes servers are experiencing issues."
        case "duplicate":
            title = "Duplicate item"
            description = "An item with the same ID is already found in your wishlist."
        case "price type problem":
            title = "Price could not be found"
            description = "There may have been a change in the pricing data of your item, try re-adding it to you wishlist."
        case "bad info":
            title = "Unexpected results"
            description = "The server responded with something unexpected. It may be overwhelmed so try again later. It also could be that there was a major change and Wishlist+ needs to update to reflect those changes."
        case "type not implemented":
            title = "Item type not implemented"
            description = "The type of item you are trying to add has not been implemented."
        default:
            title = "Unknown error"
            description = "This is bad. Contact me and tell me you received unknown error '\(error)'"
        }
        let ac = UIAlertController(title: title, message: description, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            ac.dismiss(animated: true)
        }))
        return ac
    }
    
    static func addShadow(view: UIView, fast: Bool) {
        let layer = view.layer
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5
        if fast {
            layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        }
    }
    
    static func notDuplicateID(id: String, list: [Item]) -> Bool {
        if list.contains(where: { $0.appID == Int(id) }) {
            return false
        }
        else {
            return true
        }
    }
    
    static func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    static func putShadowOnView(viewToWorkUpon: UIView) {
        
        var shadowFrame = CGRect.zero // Modify this if needed
        shadowFrame.size.width = 0.0
        shadowFrame.size.height = 0.0
        shadowFrame.origin.x = 0.0
        shadowFrame.origin.y = 0.0
        
        let shadow = UIView(frame: shadowFrame)//[[UIView alloc] initWithFrame:shadowFrame];
        shadow.isUserInteractionEnabled = false; // Modify this if needed
        shadow.layer.shadowColor = UIColor.lightGray.cgColor
        shadow.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadow.layer.shadowRadius = 1
        shadow.layer.masksToBounds = false
        shadow.clipsToBounds = false
        shadow.layer.shadowOpacity = 0.8
        viewToWorkUpon.superview?.insertSubview(shadow, belowSubview: viewToWorkUpon)
        shadow.addSubview(viewToWorkUpon)
    }
    
    //    Return formatted price based on currency and double
    static func getPriceString(price: Double, currency: String) -> String {
        if price == 0.0 {
            switch (currency)
            {
            case "USD":
                return "Free"
            case "CNY":
                return "自由"
            case "JPY":
                return "無料"
            case "GBP":
                return "Free"
            case "RUB":
                return "Free"
            case "EUR":
                return "Free"
            case "CAD":
                return "Free"
            case "AUD":
                return "Free"
            case "CHF":
                return "Free"
            case "SEK":
                return "fri"
            default:
                return "Free"
            }
        }
        switch (currency)
        {
        case "USD":
            return "$\(price)"
        case "CNY":
            return "¥\(price)"
        case "JPY":
            return "¥\(price)"
        case "GBP":
            return "£\(price)"
        case "RUB":
            return "₽\(price)"
        case "EUR":
            return "€\(price)"
        case "CAD":
            return "$\(price)"
        case "AUD":
            return "$\(price)"
        case "CHF":
            return "\(price)"
        case "SEK":
            return "\(price)"
        default:
            return "\(price)"
        }
    }
    
    //    Return true if has haptic feedback
    //    Manually updated with each new phone release
    static func platform() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    static var hasHapticFeedback: Bool {
        return ["iPhone9,1", "iPhone9,3", "iPhone9,2", "iPhone9,4"].contains(platform())
    }
    
    //     Give object and key and it will be saved
    static func save(object: Any, key: String) {
        let savedObject = NSKeyedArchiver.archivedData(withRootObject: object)
        let defaults = UserDefaults.standard
        defaults.set(savedObject, forKey: key)
        return
    }
    
    //    Funtions to load individual objects
    static func loadList() -> [Item]? {
        let defaults = UserDefaults.standard
        if let savedList = defaults.object(forKey: "list") as? Data {
            print("list found")
            let list = NSKeyedUnarchiver.unarchiveObject(with: savedList) as! [Item]
            return list
        } else {
            print("save not found")
            return nil
        }
    }
    
    static func loadSettings() -> Settings? {
        let defaults = UserDefaults.standard
        if let savedSettings = defaults.object(forKey: "settings") as? Data {
            print("settings found")
            let settings = NSKeyedUnarchiver.unarchiveObject(with: savedSettings) as? Settings
            return settings
        } else {
            print("settings not found")
            return nil
        }
    }
    
    static func loadQueue() -> [Int]? {
        if let savedQueue = UserDefaults.standard.object(forKey: "queue") as? Data {
            print("queue found")
            let queue = NSKeyedUnarchiver.unarchiveObject(with: savedQueue) as? [Int]!
            return queue
        } else {
            print("queue not found")
            return nil
        }
    }
    
    static func loadLastRefresh() -> Date {
        if let savedRefresh = UserDefaults.standard.object(forKey: "lastRefreshed") as? Data {
            print("lastRefreshed found")
            let lastRefreshed = NSKeyedUnarchiver.unarchiveObject(with: savedRefresh) as? Date
            return lastRefreshed ?? Date()
        } else {
            print("queue not found")
            return Date()
        }
    }
    
    //    Funtion to get UIIamge from url
    static func getImage(url: String) -> UIImage {
        let url = URL(string: url)
        let data: Data? = try? Data(contentsOf: url!)
        //         Implicit unwrap may throw error
        // TEST THIS ITS PROBABLY A PROBLEM
        return UIImage(data: data!) ?? UIImage()
    }
}
