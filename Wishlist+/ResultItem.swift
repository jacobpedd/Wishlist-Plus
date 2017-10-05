//
//  ResultItem.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 3/18/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import Foundation
import UIKit

class ResultItem: NSObject, NSCoding {
    var appName: String = String()
    var kind: String = String()
    var appID: Int = Int()
    var thumbnail: UIImage? = UIImage()
    var thumbnailString: String = String()
    var price: String = String()
    
    init(appName: String, kind: String, appID: Int, thumbnail: UIImage?, thumbnailString: String, price: String) {
        self.appName = appName
        self.kind = kind
        self.appID = appID
        self.thumbnail = thumbnail
        self.thumbnailString = thumbnailString
        self.price = price

    }
    
    required init(coder aDecoder: NSCoder) {
        appName = aDecoder.decodeObject(forKey: "appName") as! String
        kind = aDecoder.decodeObject(forKey: "kind") as! String
        appID = aDecoder.decodeInteger(forKey: "appID")
        thumbnail = (aDecoder.decodeObject(forKey: "thumbnail") as? UIImage)
        thumbnailString = aDecoder.decodeObject(forKey: "thumbnailString") as! String
        price = aDecoder.decodeObject(forKey: "price") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(appName, forKey: "appName")
        aCoder.encode(kind, forKey: "kind")
        aCoder.encode(appID, forKey: "appID")
        aCoder.encode(thumbnail, forKey: "thumbnail")
        aCoder.encode(thumbnailString, forKey: "thumbnailString")
        aCoder.encode(price, forKey: "price")
    }
}
