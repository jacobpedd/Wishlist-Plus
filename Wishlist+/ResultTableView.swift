//
//  ResultTableView.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 4/3/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import UIKit

class ResultTableView: UITableViewController {

    var results = [ResultItem]()
    var queue: [Int]? = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        
        if let temp = Helper.loadQueue() {
            queue = temp
            print(queue ?? "none")
        }
        
        if results.count == 0 {
            present(Helper.throwError(error: "no results"), animated: true, completion: nil)
        }
        for result in results {
            DispatchQueue.global(qos: .userInitiated).async {
                result.thumbnail = Helper.getImage(url: result.thumbnailString)
                DispatchQueue.main.sync {
                    if let temp = self.tableView.indexPathsForSelectedRows {
                        let selectedArray = temp
                        self.tableView.reloadData()
                        for index in selectedArray {
                            self.tableView.selectRow(at: index, animated: true, scrollPosition: .none)
                        }
                    } else {
                    self.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Table view data source
    
    override func viewWillDisappear(_ animated: Bool) {
        if !(queue?.isEmpty)! {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        let cell = tableView.cellForRow(at: indexPath) as! ResultCell
        
        if !(queue?.contains(cell.id))!{
            queue?.append(cell.id)
        }
        
        Helper.save(object: queue!, key: "queue")
        print(queue ?? "queue not found")
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ResultCell

        if let temp = Helper.loadQueue() {
            queue = temp
        }
        queue = queue?.filter() { $0 != cell.id }
        Helper.save(object: queue!, key: "queue")
        print(queue ?? "queue not found")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        let item = results[indexPath.row]
        cell.AppName.text = item.appName
        cell.Kind.text = item.kind
        cell.id = item.appID
        cell.Thumbnail.image = item.thumbnail
        cell.Price.text = item.price
        
        if item.kind == "App" {
            cell.Thumbnail.layer.cornerRadius = 12
            cell.Thumbnail.clipsToBounds = true
        } else {
            cell.Thumbnail.layer.cornerRadius = 0.0
            cell.Thumbnail.clipsToBounds = false
        }
        return cell
    }
}
