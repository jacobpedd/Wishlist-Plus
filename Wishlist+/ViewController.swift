//
//  ViewController.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 3/18/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import UIKit
import UserNotifications

class MainViewController: UITableViewController, UITextFieldDelegate {
    
    var list = [Item]()
    var settings: Settings?
    var queue: [Int]? = [Int]()
    @IBOutlet weak var textField: UITextField!
    var lastRefreshed = Date()
    var checkingPosition = Int()
    var affiliateString = "&at=1000lwhe"
    let tableRefreshControl = UIRefreshControl()
    
    
    @IBAction func rightPressed(_ sender: UIBarButtonItem) {
        
        let title = self.navigationItem.rightBarButtonItem?.title ?? "nil"
        switch (title) {
        case "Edit":
            setSaveButton()
            setTrashButton()
            break
        case "Save":
            setEditButton()
            setSettingsButton()
            break
        case "?":
            let ac = UIAlertController(title: "About Search", message: "Use this text field to add items to your wishlist. You can paste a link to the items store page or search for the item by name. The search is powered by the iTunes Search API, as a result, if the API is down search may be unavailable.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                ac.dismiss(animated: true)
            }))
            present(ac, animated: true, completion: nil)
            break
        default:
            print(title)
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier:
        String, sender: Any?) -> Bool {
        if identifier == "settignsSegue" {
            if textField.isEditing {
                textField.text = String()
                setEditButton()
                setSettingsButton()
                textField.endEditing(true)
                tableView.isScrollEnabled = true
                return false
            } else if tableView.isEditing {
                print("ok")
                var rows =
                    self.tableView.indexPathsForSelectedRows?.map{$0.row}
                let rowsIndex =
                    self.tableView.indexPathsForSelectedRows
                rows = rows?.sorted()
                rows?.reverse()
                print(list.count)
                if (rows != nil) {
                    tableView.beginUpdates()
                    for row in rows! {
                        self.list.remove(at: row)
                    }
                    tableView.deleteRows(at: rowsIndex ??
                        [IndexPath()], with: .left)
                    tableView.endUpdates()
                }
                Helper.save(object: list, key: "list")
                self.syncTable()
                if Helper.hasHapticFeedback {
                    let generator =
                        UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                return false
            }
            let backButton = UIBarButtonItem()
            backButton.title = "Apply"
            navigationItem.backBarButtonItem = backButton
            return true
        } else {
            return true
        }
    }
    
    func setEditButton() {
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        self.navigationItem.rightBarButtonItem?.style = .plain
        self.tableView.setEditing(false, animated: true)
    }
    func setSaveButton() {
        self.navigationItem.rightBarButtonItem?.title = "Save"
        self.navigationItem.rightBarButtonItem?.style = .done
        self.tableView.setEditing(true, animated: true)
    }
    func setQuestionButton() {
        self.navigationItem.rightBarButtonItem?.title = "?"
        self.navigationItem.rightBarButtonItem?.style = .plain
    }
    
    func setSettingsButton() {
        self.navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "settings")
        self.navigationItem.leftBarButtonItem?.title = nil
        self.navigationItem.leftBarButtonItem?.style = .plain
        self.navigationItem.leftBarButtonItem?.tintColor = self.navigationItem.rightBarButtonItem?.tintColor
    }
    func setCancelButton() {
        self.navigationItem.leftBarButtonItem?.image = nil
        self.navigationItem.leftBarButtonItem?.title = "Cancel"
        self.navigationItem.leftBarButtonItem?.style = .done
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
    }
    func setTrashButton() {
        self.navigationItem.leftBarButtonItem?.image = nil
        self.navigationItem.leftBarButtonItem?.title = "Delete"
        self.navigationItem.leftBarButtonItem?.style = .done
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        tableRefreshControl.addTarget(self, action: #selector(checkPrices), for: UIControlEvents.valueChanged)
        tableView.addSubview(tableRefreshControl)
        tableView.tableFooterView = UIView(frame: .zero)
        Helper.addShadow(view: (self.navigationController?.navigationBar)!, fast: false )
        // Used to clear user defaults
        /*
         let IDs = ["904071710", "808296431", "697846300", "1150135681", "950335311", "1152474226", "718043190", "989178902", "290986013", "1179624268", "422559334"]
         UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
         UserDefaults.standard.synchronize()
         print("clear is on")
         UIApplication.shared.isNetworkActivityIndicatorVisible = true
         addApps(IDs: IDs)
         // */
        
        let center  = UNUserNotificationCenter.current()
        UIApplication.shared.applicationIconBadgeNumber = 0
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        if Helper.connectedToNetwork() && !list.isEmpty{
            checkPrices()
            syncTable()
        }
        print("Done Loading")
    }
    
    // Make it easy to assign all objects to defaults
    func loadObjects() {
        if let temp = Helper.loadList() {
            list = temp
        }
        if let temp = Helper.loadSettings() {
            settings = temp
        }
        if let temp = Helper.loadQueue() {
            queue = temp
        }
    }
    
    // Used to update Settings
    override func viewWillAppear(_ animated: Bool) {
        print("appearing")
        loadObjects()
        let bool = queue?.isEmpty ?? true
        if !bool {
            DispatchQueue.global(qos: .userInitiated).async {
                var toAdd: [String]? = [String]()
                for id in self.queue! {
                    let ID = String(id)
                    print(ID)
                    if Helper.notDuplicateID(id: ID, list: self.list) {
                        toAdd?.append("\(id)")
                    } else {
                        self.throwError(error: "duplicate")
                    }
                }
                if toAdd != nil {
                    self.addApps(IDs: toAdd!)
                }
                DispatchQueue.main.sync {
                    self.queue = nil
                    Helper.save(object: self.queue as Any, key: "queue")
                    self.syncTable()
                    self.textField.isEnabled = true
                    self.textField.isHidden = false
                }
            }
        }
        
        // set default settings
        guard settings != nil else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
            return
        }
        
        if !(settings?.backgroundRefresh)! {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        } else {
            // set to every 4 hours
            UIApplication.shared.setMinimumBackgroundFetchInterval(21600)
        }
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        center.removeAllPendingNotificationRequests()
    }
    
    // Disable settings segue when editing table and text
    
    @IBAction func textTapped(_ sender: UITextField) {
        tableView.setEditing(false, animated: true)
        if !list.isEmpty {
            tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
        }
        tableView.isScrollEnabled = false
        setCancelButton()
        setQuestionButton()
        //textField.text = UIPasteboard.general.string
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setEditButton()
        setSettingsButton()
        textField.isHidden = true
        showRefresh()
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.getAppFromString(string: textField.text ?? "")
            DispatchQueue.main.sync {
                self.textField.text =  ""
                self.textField.isHidden = false
                self.textField.resignFirstResponder()
                self.tableRefreshControl.endRefreshing()
                return
            }
        }
        tableView.isScrollEnabled = true
        return true
    }
    
    
    func getAppFromString(string: String) {
        var responseUrl = String()
        guard string != "" else {
            print("empty String")
            return
        }
        
        if string.contains("https://appsto.re") {
            // Get sharecode on its own
            // https://appsto.re/us/ OZETF.i
            
            // Seperate by /
            let seperatedString = string.components(separatedBy: "/")
            print(seperatedString)
            
            // Seperated by " "
            guard let seperatedAgain = seperatedString.last?.components(separatedBy: " ") else {
                throwError(error: "bad link")
                return
            }
            print(seperatedAgain)
            
            //
            guard let shareCodeString = seperatedAgain.first else {
                throwError(error: "bad link")
                textField.isHidden = false
                return
            }
            
            // Recreate the share url
            let shareString = "appsto.re/\(settings?.region ?? "us")/\(shareCodeString)"
            
            guard let url = URL(string: "https://unshorten.me/s/\(shareString)") else {
                throwError(error: "bad link")
                return
            }
            
            // Task to receive final link
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                
                let datastring = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) ?? "fail"
                self.getFromItunesLink(string: datastring)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
            task.resume()
            
            
            return
        } else if string.contains("https://itun.es") {
            // Get sharecode on its own
            // https://appsto.re/us/ OZETF.i
            
            // Seperate by /
            let seperatedString = string.components(separatedBy: "/")
            print(seperatedString)
            
            // Seperated by " "
            guard let seperatedAgain = seperatedString.last?.components(separatedBy: " ") else {
                throwError(error: "bad link")
                return
            }
            print(seperatedAgain)
            
            //
            guard let shareCodeString = seperatedAgain.first else {
                throwError(error: "bad link")
                return
            }
            
            // Recreate the share url
            guard let shareURL = URL(string: "https://appsto.re/\(settings?.region ?? "us")/\(shareCodeString)")?.absoluteURL else {
                throwError(error: "bad link")
                return
            }
            print(shareURL)
            
            // Task to receive final link
            let task = URLSession.shared.dataTask(with: shareURL as URL) { data, response, error in
                responseUrl = (response?.url?.absoluteString)!
                print(responseUrl)
                self.getFromItunesLink(string: responseUrl)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
            task.resume()
            
            
        } else if string.contains("https://itunes.apple.com") {
            getFromItunesLink(string: string)
        } else {
            guard let saferString = string.stringByAddingPercentEncodingForFormData(plusForSpace: true) else {
                throwError(error: "bad link")
                return
            }
            //
            //// To add apps back put them back in results
            //// iPadSoftware,macSoftware,software,
            //
            guard let url = URL(string:"https://itunes.apple.com/search?term=\(saferString)&entity=ebook,album,tvSeason,movie&country=\(settings?.region ?? "us")") else {
                throwError(error: "bad link")
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                throwError(error: "network problem")
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throwError(error: "bad info")
                return
            }
            
            guard let results = json?["results"] as? NSArray else {
                throwError(error: "bad info")
                return
            }
            
            var resultItems = [ResultItem]()
            
            for result in results {
                let resultItem = ResultItem(appName: String(), kind: String(), appID: Int(), thumbnail: UIImage(), thumbnailString: String(), price: String())
                
                guard let dict = result as? [String: Any] else {
                    return
                }
                
                var appName = String()
                var kind = String()
                var ID = Int()
                var currency = String()
                var price = Double()
                
                if let temp = dict["currency"] as? String {
                    currency = temp
                }
                guard let thumbnailString = dict["artworkUrl60"] as? String else {
                    throwError(error: "thumbnail not found")
                    return
                }
                
                
                if let resultsKind = dict["kind"] as? String {
                    appName = dict["trackName"] as! String
                    ID = dict["trackId"] as! Int
                    switch (resultsKind)
                    {
                    case "software":
                        kind = "App"
                        break
                    case "ebook":
                        kind = "Book"
                        break
                    case "feature-movie":
                        kind = "Movie"
                        break
                    case "mac-software":
                        kind = "Mac App"
                        break
                    case "ipad-software":
                        kind = "App"
                        break
                    default:
                        print(resultsKind)
                        continue
                    }
                } else if let collectionType = dict["collectionType"] as? String {
                    appName = dict["collectionName"] as! String
                    ID = dict["collectionId"] as! Int
                    switch (collectionType)
                    {
                    case "Album":
                        print("ok")
                        kind = "Album"
                        guard dict["collectionPrice"] != nil else {
                            continue
                        }
                        break
                    case "TV Season":
                        kind = "TV Show"
                        break
                    default:
                        print(collectionType)
                        continue
                    }
                }
                switch (kind)
                {
                case "App", "Book", "Mac App":
                    if (dict["price"] as? Double) != nil {
                        price = dict["price"] as! Double
                    } else {
                        price = 0.0
                    }
                case "Album":
                    price = dict["collectionPrice"] as! Double
                case "Movie":
                    if let trackRentalPrice = dict["trackRentalPrice"] as? Double {
                        price = trackRentalPrice
                    }
                    if let trackHdRentalPrice = dict["trackHdRentalPrice"] as? Double {
                        price = trackHdRentalPrice
                    }
                    if let trackPrice = dict["trackPrice"] as? Double {
                        price = trackPrice
                    }
                    if let trackHdPrice = dict["trackHdPrice"] as? Double {
                        price = trackHdPrice
                    }
                case "TV Season":
                    if let collectionRentalPrice = dict["collectionRentalPrice"] as? Double {
                        price = collectionRentalPrice
                    }
                    if let collectionHdRentalPrice = dict["collectionHdRentalPrice"] as? Double {
                        price = collectionHdRentalPrice
                    }
                    if let collectionPrice = dict["collectionPrice"] as? Double {
                        price = collectionPrice
                    }
                    if let collectionHdPrice = dict["collectionHdPrice"] as? Double {
                        price = collectionHdPrice
                    }
                default:
                    if dict["collectionType"] as? String == "TV Season" {
                        if let collectionRentalPrice = dict["collectionRentalPrice"] as? Double {
                            price = collectionRentalPrice
                        }
                        if let collectionHdRentalPrice = dict["collectionHdRentalPrice"] as? Double {
                            price = collectionHdRentalPrice
                        }
                        if let collectionPrice = dict["collectionPrice"] as? Double {
                            price = collectionPrice
                        }
                        if let collectionHdPrice = dict["collectionHdPrice"] as? Double {
                            price = collectionHdPrice
                        }
                    } else {
                        resultItem.price = "Free"
                    }
                }
                resultItem.price = Helper.getPriceString(price: price, currency: currency)
                resultItem.appName = appName
                resultItem.kind = kind
                resultItem.appID = ID
                resultItem.thumbnailString = thumbnailString
                if resultItems.contains(where: {$0.appName == resultItem.appName && $0.price == resultItem.price}) {
                    
                } else {
                    resultItems.append(resultItem)
                }
            }
            
            DispatchQueue.main.sync {
                let rc : ResultTableView = storyboard!.instantiateViewController(withIdentifier: "ResultTableView") as! ResultTableView
                
                rc.results = resultItems
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Have to set backbutton here
                let backButton = UIBarButtonItem()
                backButton.title = "Done"
                navigationItem.backBarButtonItem = backButton
                
                navigationController?.pushViewController(rc, animated: true)
            }
        }
    }
    
    func getFromItunesLink(string: String) {
        let seperatedString = string.components(separatedBy: "/")
        print(seperatedString)
        guard let seperatedAgainString: [String]? = (seperatedString.last?.components(separatedBy: "?")) else {
            self.throwError(error: "bad link")
            return
        }
        print(seperatedAgainString!)
        guard var id = seperatedAgainString?[0] else {
            self.throwError(error: "bad link")
            return
        }
        print(id)
        id = id.replacingOccurrences(of: "id", with: "")
        print(id)
        if (Helper.notDuplicateID(id: id, list: list)) {
            print("not dup")
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.addApp(ID: id)
        } else {
            self.throwError(error: "duplicate")
        }
        
    }
    
    func checkPrices() {
        var itemsOnSale = [Item]()
        DispatchQueue.global(qos: .userInitiated).async {
            var lookupstring = "https://itunes.apple.com/lookup?id="
            for item in self.list{
                lookupstring.append(String(item.appID))
                lookupstring.append(",")
            }
            lookupstring.remove(at: lookupstring.index(before: lookupstring.endIndex))
            lookupstring.append("&country=\(self.settings?.region ?? "us")")
            
            guard let url = URL(string: lookupstring) else {
                self.throwError(error: "bad link")
                self.tableRefreshControl.endRefreshing()
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                self.throwError(error: "network problem")
                self.tableRefreshControl.endRefreshing()
                return
            }
            
            guard
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let results = json?["results"] as? NSArray else {
                    self.throwError(error: "bad info")
                    self.tableRefreshControl.endRefreshing()
                    return
            }
            
            var newPrices = [Double]()
            
            for (index, result) in results.enumerated() {
                if let dict = result as? [String: Any] {
                    let priceString = self.list[index].priceOptions[self.list[index].priceSelected]
                    
                    if let price = dict[priceString ?? "price"] as? Double {
                        newPrices.append(price)
                    } else {
                        print("here")
                        self.throwError(error: "bad info")
                        self.tableRefreshControl.endRefreshing()
                        return
                    }
                }
            }
            
            var oldFormattedPrice = String()
            for (index, newPrice) in newPrices.enumerated() {
                let item = self.list[index]
                let salePrice = item.lessThanPrice
                oldFormattedPrice = item.formattedPrice
                if (newPrice > salePrice) {
                    item.onSale = false
                    item.price = newPrice
                    item.formattedPrice = Helper.getPriceString(price: newPrice, currency: item.currency)
                    self.list[index] = item
                    print("no sale")
                } else if (newPrice <= salePrice) {
                    if !item.onSale! {
                        itemsOnSale.append(item)
                        item.onSale = true
                        item.price = newPrice
                        item.formattedPrice = Helper.getPriceString(price: newPrice, currency: item.currency)
                        self.list[index] = item
                    }
                    print("sale")
                }
            }
            
            for item in itemsOnSale {
                // send push notification
                let content = UNMutableNotificationContent()
                content.title = "An Item on Your Wishlist is On Sale!"
                content.body = "\(item.appName) went on sale from \(oldFormattedPrice) to \(item.formattedPrice)."
                content.sound = UNNotificationSound.default()
                content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
                content.categoryIdentifier = "default"
                content.userInfo["link"] = item.linkString
                
                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: 0.1,
                    repeats: false)
                let request = UNNotificationRequest(
                    identifier: "\(item.appID).notification",
                    content: content,
                    trigger: trigger
                )
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)
            }
            
            DispatchQueue.main.async {
                Helper.save(object: self.list, key: "list")
                self.syncTable()
                
                let state = UIApplication.shared.applicationState
                
                if state == .active {
                    self.tableRefreshControl.endRefreshing()
                }
                self.lastRefreshed = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, YYYY' at 'HH:mm"
                let date = formatter.string(from: self.lastRefreshed)
                Helper.save(object: self.lastRefreshed, key: "lastRefreshed")
                let dateString = "Last updated on \(date)."
                self.tableRefreshControl.attributedTitle = NSAttributedString(string: dateString)
                print(UIApplication.shared.backgroundTimeRemaining)
                return
            }
        }
    }
    
    func showRefresh() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.tableRefreshControl.beginRefreshing()
        
        if fabs(self.tableView.contentOffset.y) < CGFloat(Float.ulpOfOne)  {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.tableView.contentOffset = CGPoint(x: 0, y: -self.tableRefreshControl.frame.size.height);
            }, completion: nil)
        }
    }
    
    func syncTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func throwError(error: String) {
        let state = UIApplication.shared.applicationState
        
        if state == .active {
            DispatchQueue.main.sync {
                present(Helper.throwError(error: error), animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = list.count
        if list.isEmpty {
            let x = tableView.center.x
            let y = tableView.center.y
            let label = UILabel(frame: CGRect(x: x, y: y, width: 200, height: 0))
            
            let boldText  = "Your wishlist is empty!\n"
            let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 20)]
            let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
            
            let normalText = "Use the searchbar at the top\n to find new items!"
            let normalString = NSMutableAttributedString(string:normalText)
            
            attributedString.append(normalString)
            
            label.font = label.font.withSize(20)
            
            label.attributedText = attributedString
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.numberOfLines = 0
            label.textColor = UIColor.darkGray
            label.sizeToFit()
            label.textAlignment = .center
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemCell
        let item = list[indexPath.row]
        
        cell.appName.text = item.appName
        cell.kind.text = item.kind
        cell.price.setTitle(item.formattedPrice,for: .normal)
        cell.price.setTitle(item.formattedPrice,for: .highlighted)
        cell.thumbnail.image = item.thumbnail
        cell.onSale = item.onSale ?? false
        cell.link = item.linkString
        
        if cell.onSale {
            cell.price.backgroundColor = UIColor(red: 0.1608, green: 0.698, blue: 0, alpha: 1.0)
        } else if !cell.onSale {
            cell.price.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        }
        
        if item.kind == "App" {
            cell.thumbnail.layer.cornerRadius = 12
            cell.thumbnail.clipsToBounds = true
        } else {
            cell.thumbnail.layer.cornerRadius = 0.0
            cell.thumbnail.clipsToBounds = false
        }
        
        //Helper.putShadowOnView(viewToWorkUpon: cell.thumbnail)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = list[sourceIndexPath.row]
        list.remove(at: sourceIndexPath.row)
        list.insert(itemToMove, at: destinationIndexPath.row)
        Helper.save(object: list, key: "list")
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") {action in
            tableView.beginUpdates()
            self.list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
            if Helper.hasHapticFeedback {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
        }
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if Helper.hasHapticFeedback {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !textField.isEditing {
            let item = list[indexPath.row]
            if !tableView.isEditing {
                
                
                if item.kind == "Movie" || item.kind == "TV Show" {
                    if item.price != 0 {
                        let vc : DetailViewControllerVideo = storyboard!.instantiateViewController(withIdentifier: "DetailViewControllerVideo") as! DetailViewControllerVideo
                        vc.itemIndex = indexPath.row
                        // Have to set backbutton here
                        let backButton = UIBarButtonItem()
                        backButton.title = ""
                        navigationItem.backBarButtonItem = backButton
                        navigationController?.pushViewController(vc, animated: true)
                        tableView.deselectRow(at: indexPath, animated: true)
                        return
                    } else {
                        let vc : DetailViewControllerFreeVideo = storyboard!.instantiateViewController(withIdentifier: "DetailViewControllerFreeVideo") as! DetailViewControllerFreeVideo
                        vc.itemIndex = indexPath.row
                        // Have to set backbutton here
                        let backButton = UIBarButtonItem()
                        backButton.title = ""
                        navigationItem.backBarButtonItem = backButton
                        navigationController?.pushViewController(vc, animated: true)
                        tableView.deselectRow(at: indexPath, animated: true)
                        return
                    }
                } else {
                    if item.price != 0 {
                        let vc : DetailViewController = storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                        vc.itemIndex = indexPath.row
                        // Have to set backbutton here
                        let backButton = UIBarButtonItem()
                        backButton.title = ""
                        navigationItem.backBarButtonItem = backButton
                        navigationController?.pushViewController(vc, animated: true)
                        tableView.deselectRow(at: indexPath, animated: true)
                        return
                    } else {
                        let vc : DetailViewControllerFree = storyboard!.instantiateViewController(withIdentifier: "DetailViewControllerFree") as! DetailViewControllerFree
                        vc.itemIndex = indexPath.row
                        // Have to set backbutton here
                        let backButton = UIBarButtonItem()
                        backButton.title = ""
                        navigationItem.backBarButtonItem = backButton
                        navigationController?.pushViewController(vc, animated: true)
                        tableView.deselectRow(at: indexPath, animated: true)
                        return
                    }
                }
                
                
                
                
                
                
                
            } else {
                if !list.isEmpty {
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
                }
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.isScrollEnabled = true
            setEditButton()
            setSettingsButton()
            textField.text =  ""
            textField.endEditing(true)
        }
    }
    
    func addApp(ID: String) {
        let IDArray = [ID]
        print(IDArray)
        addApps(IDs: IDArray)
        return
    }
    
    func addApps(IDs: [String]) {
        DispatchQueue.global(qos: .userInitiated).async {
            var lookupstring = "https://itunes.apple.com/lookup?id="
            for ID in IDs {
                lookupstring.append(ID)
                lookupstring.append(",")
            }
            lookupstring.remove(at: lookupstring.index(before: lookupstring.endIndex))
            lookupstring.append("&country=\(self.settings?.region ?? "us")")
            
            guard let url = URL(string: lookupstring) else {
                self.throwError(error: "bad link")
                self.tableRefreshControl.endRefreshing()
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                self.throwError(error: "network problem")
                self.tableRefreshControl.endRefreshing()
                return
            }
            
            guard
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let results = json?["results"] as? NSArray else {
                    self.throwError(error: "bad info")
                    self.tableRefreshControl.endRefreshing()
                    return
            }
            
            for result in results {
                if let dict = result as? [String: Any] {
                    
                    let kind = dict["kind"] as? String ?? "none"
                    
                    switch (kind)
                    {
                    case "software":
                        guard
                            let appName = dict["trackName"] as? String,
                            let appDescription = dict["description"] as? String,
                            let formattedPrice = dict["formattedPrice"] as? String,
                            let price = dict["price"] as? Double,
                            let currency = dict["currency"] as? String,
                            let genre = dict["primaryGenreName"] as? String,
                            let sellerName = dict["sellerName"] as? String,
                            let linkString = dict["trackViewUrl"] as? String,
                            let thumbnailString = dict["artworkUrl512"] as? String,
                            let appID = dict["trackId"] as? Int else {
                                self.throwError(error: "bad info")
                                return
                        }
                        
                        let item = Item(appName: String(), appDescription: String(), formattedPrice: String(), price: Double(), currency: String(), lessThanPrice: Double(), priceOptions: [String: String](), priceSelected: String(), kind: String(), genre: String(), sellerName: String(), linkString: String(), appID: Int(), thumbnail: UIImage(), onSale: false)
                        
                        item.kind = "App"
                        
                        item.appName = appName
                        item.appDescription = appDescription
                        item.formattedPrice = formattedPrice
                        item.price = price
                        item.currency = currency
                        item.lessThanPrice = item.price - 1
                        item.priceOptions["default"] = "price"
                        item.priceSelected = "default"
                        
                        item.genre = genre
                        item.sellerName = sellerName
                        item.linkString = linkString + self.affiliateString
                        // + self.affiliateString
                        item.appID = appID
                        item.thumbnail = Helper.getImage(url: thumbnailString)
                        
                        DispatchQueue.main.async {
                            self.list.insert(item, at: 0)
                            print(item.appID)
                            Helper.save(object: self.list, key: "list")
                            self.tableView.reloadData()
                        }
                        continue
                        
                    case "mac-software":
                        guard
                            let appName = dict["trackName"] as? String,
                            let appDescription = dict["description"] as? String,
                            let formattedPrice = dict["formattedPrice"] as? String,
                            let price = dict["price"] as? Double,
                            let currency = dict["currency"] as? String,
                            let genre = dict["primaryGenreName"] as? String,
                            let sellerName = dict["sellerName"] as? String,
                            let linkString = dict["trackViewUrl"] as? String,
                            let thumbnailString = dict["artworkUrl512"] as? String,
                            let appID = dict["trackId"] as? Int else {
                                self.throwError(error: "bad info")
                                return
                        }
                        
                        let item = Item(appName: String(), appDescription: String(), formattedPrice: String(), price: Double(), currency: String(), lessThanPrice: Double(), priceOptions: [String: String](), priceSelected: String(), kind: String(), genre: String(), sellerName: String(), linkString: String(), appID: Int(), thumbnail: UIImage(), onSale: false)
                        
                        item.kind = "Mac App"
                        
                        item.appName = appName
                        item.appDescription = appDescription
                        item.formattedPrice = formattedPrice
                        item.price = price
                        item.currency = currency
                        item.lessThanPrice = item.price - 1
                        item.priceOptions["default"] = "price"
                        item.priceSelected = "default"
                        
                        item.genre = genre
                        item.sellerName = sellerName
                        item.linkString = linkString + self.affiliateString
                        // + self.affiliateString
                        item.appID = appID
                        item.thumbnail = Helper.getImage(url: thumbnailString)
                        
                        DispatchQueue.main.async {
                            self.list.insert(item, at: 0)
                            print(item.appID)
                            Helper.save(object: self.list, key: "list")
                            self.tableView.reloadData()
                        }
                        continue
                        
                    case "feature-movie":
                        guard
                            let appName = dict["trackName"] as? String,
                            let appDescription = dict["longDescription"] as? String,
                            let genre = dict["primaryGenreName"] as? String,
                            let sellerName = dict["artistName"] as? String,
                            let linkString = dict["trackViewUrl"] as? String,
                            let thumbnailString = dict["artworkUrl100"] as? String,
                            let appID = dict["trackId"] as? Int,
                            let currency = dict["currency"] as? String else {
                                self.throwError(error: "bad info")
                                return
                        }
                        let item = Item(appName: String(), appDescription: String(), formattedPrice: String(), price: Double(), currency: String(), lessThanPrice: Double(), priceOptions: [String: String](), priceSelected: String(), kind: String(), genre: String(), sellerName: String(), linkString: String(), appID: Int(), thumbnail: UIImage(), onSale: false)
                        
                        item.kind = "Movie"
                        
                        item.appName = appName
                        item.appDescription = appDescription
                        item.genre = genre
                        item.sellerName = sellerName
                        item.linkString = linkString + self.affiliateString
                        item.appID = appID
                        item.thumbnail = Helper.getImage(url: thumbnailString)
                        
                        // Multiple price points for movies
                        var prices = [String: String]()
                        var price = Double()
                        
                        if let trackRentalPrice = dict["trackRentalPrice"] as? Double {
                            prices["RentSD"] = "trackRentalPrice"
                            item.priceSelected = "RentSD"
                            price = trackRentalPrice
                        }
                        if let trackHdRentalPrice = dict["trackHdRentalPrice"] as? Double {
                            prices["RentHD"] = "trackHdRentalPrice"
                            item.priceSelected = "RentHD"
                            price = trackHdRentalPrice
                        }
                        if let trackPrice = dict["trackPrice"] as? Double {
                            prices["BuySD"] = "trackPrice"
                            item.priceSelected = "BuySD"
                            price = trackPrice
                        }
                        if let trackHdPrice = dict["trackHdPrice"] as? Double {
                            prices["BuyHD"] = "trackHdPrice"
                            item.priceSelected = "BuyHD"
                            price = trackHdPrice
                        }
                        
                        item.price = price.roundTo(places: 2)
                        item.currency = currency
                        item.formattedPrice = Helper.getPriceString(price: price, currency: currency)
                        item.lessThanPrice = item.price - 1
                        item.priceOptions = prices
                        
                        DispatchQueue.main.async {
                            self.list.insert(item, at: 0)
                            print(item.appID)
                            Helper.save(object: self.list, key: "list")
                            self.tableView.reloadData()
                        }
                        continue
                        
                        
                    case "ebook":
                        guard
                            let appName = dict["trackName"] as? String,
                            let appDescription = dict["description"] as? String,
                            let genre = dict["genres"] as? [String],
                            let sellerName = dict["artistName"] as? String,
                            let linkString = dict["trackViewUrl"] as? String,
                            let thumbnailString = dict["artworkUrl100"] as? String,
                            let appID = dict["trackId"] as? Int,
                            let price = dict["price"] as? Double,
                            let currency = dict["currency"] as? String,
                            let formattedPrice = dict["formattedPrice"] as? String else{
                                self.throwError(error: "bad info")
                                return
                        }
                        let item = Item(appName: String(), appDescription: String(), formattedPrice: String(), price: Double(), currency: String(), lessThanPrice: Double(), priceOptions: [String: String](), priceSelected: String(), kind: String(), genre: String(), sellerName: String(), linkString: String(), appID: Int(), thumbnail: UIImage(), onSale: false)
                        
                        item.kind = "Book"
                        
                        item.appName = appName
                        item.appDescription = String(htmlEncodedString: appDescription)
                        item.formattedPrice = formattedPrice
                        item.price = price
                        item.currency = currency
                        item.lessThanPrice = item.price - 1
                        item.priceOptions["default"] = "price"
                        item.priceSelected = "default"
                        
                        item.genre = genre.first ?? "Genre not found"
                        item.sellerName = sellerName
                        item.linkString = linkString + self.affiliateString
                        item.appID = appID
                        item.thumbnail = Helper.getImage(url: thumbnailString)
                        
                        DispatchQueue.main.async {
                            self.list.insert(item, at: 0)
                            print(item.appID)
                            Helper.save(object: self.list, key: "list")
                            self.tableView.reloadData()
                        }
                        
                        continue
                        
                    default:
                        print("kind: '\(kind)' not implemented")
                        break
                    }
                    
                    let collectionType = dict["collectionType"] as? String ?? "none"
                    
                    switch (collectionType)
                    {
                    case "Album":
                        guard
                            let appName = dict["collectionName"] as? String,
                            let genre = dict["primaryGenreName"] as? String,
                            let sellerName = dict["artistName"] as? String,
                            let linkString = dict["collectionViewUrl"] as? String,
                            let thumbnailString = dict["artworkUrl100"] as? String,
                            let appID = dict["collectionId"] as? Int,
                            let price = dict["collectionPrice"] as? Double,
                            let currency = dict["currency"] as? String else{
                                self.throwError(error: "bad info")
                                return
                        }
                        let item = Item(appName: String(), appDescription: String(), formattedPrice: String(), price: Double(), currency: String(), lessThanPrice: Double(), priceOptions: [String: String](), priceSelected: String(), kind: String(), genre: String(), sellerName: String(), linkString: String(), appID: Int(), thumbnail: UIImage(), onSale: false)
                        
                        item.kind = "Album"
                        
                        item.appName = appName
                        item.appDescription = "No description"
                        
                        item.formattedPrice = Helper.getPriceString(price: price, currency: currency)
                        
                        item.price = price
                        item.currency = currency
                        item.lessThanPrice = item.price - 1
                        item.priceOptions["default"] = "collectionPrice"
                        item.priceSelected = "default"
                        
                        item.genre = genre
                        item.sellerName = sellerName
                        item.linkString = linkString + self.affiliateString
                        item.appID = appID
                        item.thumbnail = Helper.getImage(url: thumbnailString)
                        
                        DispatchQueue.main.async {
                            self.list.insert(item, at: 0)
                            print(item.appID)
                            Helper.save(object: self.list, key: "list")
                            self.tableView.reloadData()
                        }
                        continue
                        
                    case "TV Season":
                        guard
                            let appName = dict["collectionName"] as? String,
                            let appDescription = dict["longDescription"] as? String,
                            let genre = dict["primaryGenreName"] as? String,
                            let sellerName = dict["artistName"] as? String,
                            let linkString = dict["collectionViewUrl"] as? String,
                            let thumbnailString = dict["artworkUrl100"] as? String,
                            let appID = dict["collectionId"] as? Int,
                            let currency = dict["currency"] as? String else{
                                self.throwError(error: "bad info")
                                return
                        }
                        let item = Item(appName: String(), appDescription: String(), formattedPrice: String(), price: Double(), currency: String(), lessThanPrice: Double(), priceOptions: [String: String](), priceSelected: String(), kind: String(), genre: String(), sellerName: String(), linkString: String(), appID: Int(), thumbnail: UIImage(), onSale: false)
                        
                        item.kind = "TV Show"
                        
                        item.appName = appName
                        item.appDescription = appDescription
                        item.genre = genre
                        item.sellerName = sellerName
                        item.linkString = linkString + self.affiliateString
                        item.appID = appID
                        item.thumbnail = Helper.getImage(url: thumbnailString)
                        
                        // Multiple price points for movies
                        var prices = [String: String]()
                        var price = Double()
                        
                        if let collectionRentalPrice = dict["collectionRentalPrice"] as? Double {
                            prices["RentSD"] = "collectionRentalPrice"
                            item.priceSelected = "RentSD"
                            price = collectionRentalPrice
                        }
                        if let collectionHdRentalPrice = dict["collectionHdRentalPrice"] as? Double {
                            prices["RentHD"] = "collectionHdRentalPrice"
                            item.priceSelected = "RentHD"
                            price = collectionHdRentalPrice
                        }
                        if let collectionPrice = dict["collectionPrice"] as? Double {
                            prices["BuySD"] = "collectionPrice"
                            item.priceSelected = "BuySD"
                            price = collectionPrice
                        }
                        if let collectionHdPrice = dict["collectionHdPrice"] as? Double {
                            prices["BuyHD"] = "collectionHdPrice"
                            item.priceSelected = "BuyHD"
                            price = collectionHdPrice
                        }
                        
                        item.price = price.roundTo(places: 2)
                        item.currency = currency
                        item.formattedPrice = Helper.getPriceString(price: price, currency: currency)
                        item.lessThanPrice = item.price - 1
                        item.priceOptions = prices
                        
                        DispatchQueue.main.async {
                            self.list.insert(item, at: 0)
                            print(item.appID)
                            Helper.save(object: self.list, key: "list")
                            self.tableView.reloadData()
                        }
                        continue
                        
                    default:
                        self.throwError(error: "type not implemented")
                        break
                    }
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    
    init(htmlEncodedString: String) {
        self.init()
        guard let encodedData = htmlEncodedString.data(using: .utf8) else {
            self = htmlEncodedString
            return
        }
        
        let attributedOptions: [String : Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self = attributedString.string
        } catch {
            print("Error: \(error)")
            self = htmlEncodedString
        }
    }
}


// extension for making search results parameters
extension String {
    
    /**
     Returns a new string made from the receiver by replacing characters which are
     reserved in a URI query with percent encoded characters.
     
     The following characters are not considered reserved in a URI query
     by RFC 3986:
     
     - Alpha "a...z" "A...Z"
     - Numberic "0...9"
     - Unreserved "-._~"
     
     In addition the reserved characters "/" and "?" have no reserved purpose in the
     query component of a URI so do not need to be percent escaped.
     
     - Returns: The encoded string, or nil if the transformation is not possible.
     */
    
    public func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
    }
    
    /**
     Returns a new string made from the receiver by replacing characters which are
     reserved in HTML forms (media type application/x-www-form-urlencoded) with
     percent encoded characters.
     
     The W3C HTML5 specification, section 4.10.22.5 URL-encoded form
     data percent encodes all characters except the following:
     
     - Space (0x20) is replaced by a "+" (0x2B)
     - Bytes in the range 0x2A, 0x2D, 0x2E, 0x30-0x39, 0x41-0x5A, 0x5F, 0x61-0x7A
     (alphanumeric + "*-._")
     - Parameter plusForSpace: Boolean, when true replaces space with a '+'
     otherwise uses percent encoding (%20). Default is false.
     
     - Returns: The encoded string, or nil if the transformation is not possible.
     */
    
    public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String? {
        let unreserved = "*-._"
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: unreserved)
        
        if plusForSpace {
            allowedCharacterSet.addCharacters(in: " ")
        }
        
        var encoded = addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
        if plusForSpace {
            encoded = encoded?.replacingOccurrences(of: " ", with: "+")
        }
        return encoded
    }
}



