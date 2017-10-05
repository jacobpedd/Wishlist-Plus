//
//  Settings.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 3/28/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import UIKit

class Settings: NSObject, NSCoding {
    var backgroundRefresh: Bool? = true
    var region: String = String()
    
    
    init(backgroundRefresh: Bool, region: String) {
        self.backgroundRefresh = backgroundRefresh
        self.region = region

    }
    
    required init(coder aDecoder: NSCoder) {
        backgroundRefresh = aDecoder.decodeObject(forKey: "backgroundRefresh") as? Bool
        region = aDecoder.decodeObject(forKey: "region") as! String

    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(backgroundRefresh, forKey: "backgroundRefresh")
        aCoder.encode(region, forKey: "region")
    }
}
