//
//  AppItem.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 3/18/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import Foundation
import UIKit

class Item: NSObject, NSCoding {
    var appName: String = String()
    var appDescription: String = String()
    var formattedPrice: String = String()
    var price: Double = Double()
    var currency: String = String()
    var lessThanPrice: Double = Double()
    var priceOptions: [String: String] = [String: String]()
    var priceSelected: String = String()
    var kind: String = String()
    var genre: String = String()
    var sellerName: String = String()
    var linkString: String = String()
    var appID: Int = Int()
    var thumbnail: UIImage? = UIImage()
    var onSale: Bool? = Bool()
    
    init(appName: String, appDescription: String, formattedPrice: String, price: Double, currency: String, lessThanPrice: Double, priceOptions: [String: String], priceSelected: String, kind: String, genre: String, sellerName: String, linkString: String, appID: Int, thumbnail: UIImage?, onSale: Bool?) {
        self.appName = appName
        self.appDescription = appDescription
        self.formattedPrice = formattedPrice
        self.price = price
        self.currency = currency
        self.lessThanPrice = lessThanPrice
        self.priceOptions = priceOptions
        self.priceSelected = priceSelected
        self.kind = kind
        self.genre = genre
        self.sellerName = sellerName
        self.linkString = linkString
        self.appID = appID
        self.thumbnail = thumbnail
        self.onSale = onSale
    }
    
    required init(coder aDecoder: NSCoder) {
        appName = aDecoder.decodeObject(forKey: "appName") as! String
        appDescription = aDecoder.decodeObject(forKey: "appDescription") as! String
        formattedPrice = aDecoder.decodeObject(forKey: "formattedPrice") as! String
        price = aDecoder.decodeDouble(forKey: "price")
        currency = aDecoder.decodeObject(forKey: "currency") as! String
        lessThanPrice = aDecoder.decodeDouble(forKey: "lessThanPrice")
        priceOptions = aDecoder.decodeObject(forKey: "priceOptions") as! [String: String]
        priceSelected = aDecoder.decodeObject(forKey: "priceSelected") as! String
        kind = aDecoder.decodeObject(forKey: "kind") as! String
        genre = aDecoder.decodeObject(forKey: "genre") as! String
        sellerName = aDecoder.decodeObject(forKey: "sellerName") as! String
        linkString = aDecoder.decodeObject(forKey: "linkString") as! String
        appID = aDecoder.decodeInteger(forKey: "appID")
        thumbnail = (aDecoder.decodeObject(forKey: "thumbnail") as? UIImage)
        onSale = aDecoder.decodeObject(forKey: "onSale") as? Bool
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(appName, forKey: "appName")
        aCoder.encode(appDescription, forKey: "appDescription")
        aCoder.encode(formattedPrice, forKey: "formattedPrice")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(currency, forKey: "currency")
        aCoder.encode(lessThanPrice, forKey: "lessThanPrice")
        aCoder.encode(priceOptions, forKey: "priceOptions")
        aCoder.encode(priceSelected, forKey: "priceSelected")
        aCoder.encode(kind, forKey: "kind")
        aCoder.encode(genre, forKey: "genre")
        aCoder.encode(sellerName, forKey: "sellerName")
        aCoder.encode(linkString, forKey: "linkString")
        aCoder.encode(appID, forKey: "appID")
        aCoder.encode(thumbnail, forKey: "thumbnail")
        aCoder.encode(onSale, forKey: "onSale")
    }
}
