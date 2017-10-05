//
//  DetailViewViewController.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 3/20/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import UIKit

class DetailViewControllerFree: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var appDescription: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var price: UIButton!
    @IBOutlet weak var kind: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBAction func pricePressed(_ sender: UIButton) {
        if let url = URL(string: linkString){
            print(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    var itemIndex = Int()
    var list = [Item]()
    var prices = [Double]()
    var formattedPrices = [String]()
    var linkString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let temp = Helper.loadList() {
            list = temp
        }
        
        let item = list[itemIndex]
        title = item.appName
        linkString = item.linkString
        
        thumbnail.image = item.thumbnail
        thumbnail.layer.cornerRadius = 12
        thumbnail.clipsToBounds = true
        appDescription.text = item.appDescription
        kind.text = item.kind
        genre.text = item.genre
        
        
        price.setTitle(item.formattedPrice,for: .normal)
        price.setTitle(item.formattedPrice,for: .highlighted)
        price.layer.masksToBounds = true
        price.layer.cornerRadius = 8.0
        if item.onSale ?? false {
            price.backgroundColor = UIColor(red: 0.1608, green: 0.698, blue: 0, alpha: 1.0)
            
        } else {
            price.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        }
        price.tintColor = UIColor.white
        appDescription.sizeToFit()
        
        let componentsHeight  = CGFloat(369)
        let detailHeight = appDescription.frame.height
        let height = componentsHeight + detailHeight
        edgesForExtendedLayout = UIRectEdge()
        scrollView.contentSize.height = height
        // Do any additional setup after loading the view.
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Updates appDescription label size as device rotates
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            self.appDescription.sizeToFit()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            Helper.save(object: self.list, key: "list")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let temp = Helper.loadList() {
            list = temp
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
