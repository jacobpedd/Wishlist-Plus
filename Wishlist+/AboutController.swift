//
//  aboutController.swift
//  Wishlist+
//
//  Created by mac pro on 5/10/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import Foundation

import UIKit
import WebKit

class AboutController: UIViewController {
    var webView: WKWebView!
    let margin = 15
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var html = "<html>"
        html += "<head>"
        html += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        html += "<style> img {width:\(Int(UIScreen.main.bounds.width) - (margin * 2));} body { background-color: transparent; font-size: 120%; font-family:'-apple-system'; margin:\(margin);} </style>"
        html += "</head>"
        html += "<body>"
        html += "<h3>"
        html += "Hi, I'm Jacob Peddicord </br> Thank you for using my app!"
        html += "</h3>"
        html += "<h4>"
        html += "About me"
        html += "</h4>"
        html += "I am an independent iOS developer. I started working on this app as a senior in high school. At the time of writing this, I am about to graduate and will be attending the University of Nebraska-Lincoln. I make apps that solve the problems I have. My goal is to gain experience and create a useful tool, not make a bunch of money by sending you a million notifications a day."
        html += "<h4>"
        html += "About  Wishlist+"
        html += "</h4>"
        html += "Wishlist+ was made to be a simple utility app that allows you to be notified when an item from iTunes® goes on sale. You don't need to create an account or accept a privacy policy because the app operates without any servers or custom analytics. The app simply checks the iTunes API directly for any change in pricing. "
        html += "<h4>"
        html += "How does Wishlist+ make money?"
        html += "</h4>"
        html += "Wishlist+ is powered by the iTunes Affiliate program. This means that when you click a link to view an item in the store if you make a purchase I receive a percentage of that purchase. This allows this app to be completely free, including add free. "
        html += "<h4>"
        html += "What kind of notifications will I get?"
        html += "</h4>"
        html += "You will only get notifications when an item on your wishlist goes on sale at or below your designated target price."
        html += "<h4>"
        html += "I like what you're doing, how can I support you?"
        html += "</h4>"
        html += "Thanks! You can support me by using a Wishlist+ link with any purchase from iTunes® or the App Store®, just add that item to your wishlist and click on its link. "
        html += "</body>"
        html += "</html>"
        webView.loadHTMLString(html, baseURL: nil)
    }
}
