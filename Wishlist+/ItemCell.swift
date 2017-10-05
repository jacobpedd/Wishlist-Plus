//
//  ItemCell.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 3/18/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var kind: UILabel!
    @IBOutlet weak var price: UIButton!
    
    var onSale = Bool()
    var link = String()
    
    @IBAction func pricePressed(_ sender: UIButton) {
        if let url = URL(string: link){
            print(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        price.layer.masksToBounds = true
        price.layer.cornerRadius = 8.0
    }
    override func willTransition(to state: UITableViewCellStateMask) {
        super.willTransition(to: state)
        if state.rawValue != 0 {
            price.isHidden = true
        }
    }
    
    override func didTransition(to state: UITableViewCellStateMask) {
        super.willTransition(to: state)
        if state.rawValue == 0 {
            price.isHidden = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

