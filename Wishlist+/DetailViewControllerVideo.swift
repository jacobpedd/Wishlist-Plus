//
//  DetailViewViewController.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 3/20/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import UIKit

class DetailViewControllerVideo: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var appDescription: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var price: UIButton!
    @IBOutlet weak var kind: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBAction func pricePressed(_ sender: UIButton) {
        if let url = URL(string: linkString){
            print(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBOutlet weak var definitionOption: UISegmentedControl!
    @IBOutlet weak var rentOption: UISegmentedControl!
    @IBAction func definitionChanged(_ sender: UISegmentedControl) {
        if !Helper.connectedToNetwork(){
            if definitionOption.selectedSegmentIndex == 0 {
                definitionOption.selectedSegmentIndex = 1
            } else {
                definitionOption.selectedSegmentIndex = 0
            }
            throwError(error: "network problem")
            return
        }
        setPriceIndex()
    }
    @IBAction func rentChanged(_ sender: UISegmentedControl) {
        if !Helper.connectedToNetwork(){
            if rentOption.selectedSegmentIndex == 0 {
                rentOption.selectedSegmentIndex = 1
            } else {
                rentOption.selectedSegmentIndex = 0
            }
            throwError(error: "network problem")
            return
        }
        setPriceIndex()
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
        pickerView.delegate = self
        
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
        
        if item.kind == "TV Show" || item.kind == "Movie" {
            
            if (item.priceOptions["BuySD"] != nil) && (item.priceOptions["BuyHD"] != nil) {
                definitionOption.isEnabled = true
                if (item.priceSelected == "BuySD" || item.priceSelected == "RentSD") {
                    definitionOption.selectedSegmentIndex = 0
                }
            } else {
                definitionOption.isEnabled = false
            }
            
            if (item.priceOptions["RentSD"] != nil) && (item.priceOptions["RentHD"] != nil) {
                rentOption.isEnabled = true
                if (item.priceSelected == "RentSD" || item.priceSelected == "RentHD") {
                    rentOption.selectedSegmentIndex = 0
                }
            } else {
                rentOption.isEnabled = false
            }
            
        } else {
            definitionOption.isEnabled = false
            rentOption.isEnabled = false
        }
        
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
        if list[itemIndex].price != 0 {
            generatePickerPrices()
        }
    }
    
    func setPriceIndex() {
        let item = list[itemIndex]
        print(item.priceOptions)
        if definitionOption.isEnabled == true && rentOption.isEnabled == true {
            switch (definitionOption.selectedSegmentIndex, rentOption.selectedSegmentIndex) {
            case (0, 0):
                print("sd rent")
                item.priceSelected = "RentSD"
                break
            case (1, 0):
                print("hd rent")
                item.priceSelected = "RentHD"
                break
            case (1, 1):
                print("hd own")
                item.priceSelected = "BuyHD"
                break
            case (0, 1):
                print("sd own")
                item.priceSelected = "BuySD"
                break
            default:
                print("idk")
                break
            }
        }
        if definitionOption.isEnabled == true && rentOption.isEnabled == false {
            switch (definitionOption.selectedSegmentIndex, rentOption.selectedSegmentIndex) {
            case (0, 1):
                print("sd")
                if (item.priceOptions["BuySD"] != nil) {
                    item.priceSelected = "BuySD"
                } else if (item.priceOptions["RentSD"] != nil) {
                    item.priceSelected = "RentSD"
                }
                break
            case (1, 1):
                print("hd")
                if (item.priceOptions["BuyHD"] != nil) {
                    item.priceSelected = "BuyHD"
                } else if (item.priceOptions["RentHD"] != nil) {
                    item.priceSelected = "RentHD"
                }
                break
            default:
                print(rentOption.selectedSegmentIndex)
                print("idk")
                break
            }
        }
        if definitionOption.isEnabled == false && rentOption.isEnabled == true {
            switch (definitionOption.selectedSegmentIndex, rentOption.selectedSegmentIndex) {
            case (1, 0):
                print("rent")
                if (item.priceOptions["RentSD"] != nil) {
                    item.priceSelected = "RentSD"
                } else if (item.priceOptions["RentHD"] != nil) {
                    item.priceSelected = "RentHD"
                }
                break
            case (1, 1):
                print("buy")
                if (item.priceOptions["BuySD"] != nil) {
                    item.priceSelected = "BuySD"
                } else if (item.priceOptions["BuyHD"] != nil) {
                    item.priceSelected = "BuyHD"
                }
                break
            default:
                print("idk")
                break
            }
        }
        updatePrice()
        
    }
    
    func throwError(error: String) {
        present(Helper.throwError(error: error), animated: true, completion: nil)
    }
    
    func updatePrice() {
        // Get the app Id of the item
        let item = list[itemIndex]
        let id = item.appID
        
        // Get price of item
        guard let url = URL(string:"https://itunes.apple.com/lookup?id=\(id)") else {
            
            throwError(error: "network problem")
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            throwError(error: "network problem")
            return
        }
        
        let priceString = item.priceOptions[item.priceSelected]!
        print(priceString)
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            if let result = json?["results"] as? NSArray {
                if let dict = result[0] as? [String: Any] {
                    if let price = dict[priceString] as? Double {
                        item.price = price
                        item.formattedPrice = Helper.getPriceString(price: item.price, currency: item.currency)
                        item.lessThanPrice = item.price - 1
                        print(item.price)
                    }
                }
            }
        }
        list[itemIndex] = item
        generatePickerPrices()
        price.setTitle(String(item.formattedPrice),for: .normal)
        price.setTitle(String(item.formattedPrice),for: .highlighted)
        Helper.save(object: list, key: "list")
    }
    
    func generatePickerPrices() {
        prices = [Double]()
        var price = list[itemIndex].price
        var decreaser = Double()
        if price > 100.0 {
            decreaser = 5.0
        } else {
            decreaser = 1.0
        }
        
        while (price > 0.0) {
            prices.append(price)
            price = (price - decreaser).roundTo(places: 2)
        }
        prices.append(0.00)
        prices.remove(at: 0)
        
        formattedPrices = [String]()
        for price in prices {
            formattedPrices.append(Helper.getPriceString(price: price, currency: list[itemIndex].currency))
        }
        
        pickerView.reloadAllComponents()
        if list[itemIndex].lessThanPrice == prices[0] {
            pickerView.selectRow(0, inComponent: 0, animated: true)
        } else if let index = prices.index(of: list[itemIndex].lessThanPrice) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        } else {
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return formattedPrices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = formattedPrices[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 26),NSForegroundColorAttributeName:UIColor.black])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        list[itemIndex].lessThanPrice = prices[row]
        print(list[itemIndex].lessThanPrice)
        return
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
