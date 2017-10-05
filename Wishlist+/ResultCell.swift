//
//  ResultCellTableViewCell.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 4/3/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
    var queue: [Int]? = [Int]()
    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var AppName: UILabel!
    @IBOutlet weak var Kind: UILabel!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var Price: UILabel!

    var id: Int = Int()

    override func awakeFromNib() {
        super.awakeFromNib()
        Price.layer.masksToBounds = true
        Price.layer.cornerRadius = 8.0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
