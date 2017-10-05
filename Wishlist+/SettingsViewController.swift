//
//  SettingsViewController.swift
//  Wishlist+ Better App Wishlist
//
//  Created by mac pro on 3/26/17.
//  Copyright © 2017 Jacobs House. All rights reserved.
//

import UIKit
import MessageUI


class SettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate {
    @IBAction func backgroundRefreshChanged(_ sender: UISwitch) {
        settings.backgroundRefresh = backgroundRefreshSwitch.isOn
        Helper.save(object: settings, key: "settigns")
    }
    @IBAction func regionSelection(_ sender: Any) {
        launchCountryPicker()
    }
    @IBOutlet weak var backgroundRefreshSwitch: UISwitch!
    @IBOutlet weak var regionButton: UIButton!
    
    var settings: Settings = Settings(backgroundRefresh: true, region: String())
    let regions = [String]()
    let countries = ["United States", "Australia", "Brazil", "Canada", "China", "France", "Germany", "Great Britain", "Italy", "Japan", "Russia", "South Korea", "Sweden", "Switzerland"]
    let countryCodes = ["us", "au", "br", "ca", "cn", "fr", "de", "gb", "it", "jp", "ru", "kr", "se", "ch"]
    var row = Int()
    
    func launchCountryPicker() {
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: "Select Region", message: "", preferredStyle: UIAlertControllerStyle.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        self.present(editRadiusAlert, animated: true)
        pickerView.selectRow(row, inComponent: 0, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
        title = "Settings"
        if let temp = Helper.loadSettings(){
            settings = temp
        }
        
        row = countryCodes.index(of: settings.region) ?? 0

        backgroundRefreshSwitch.isOn = settings.backgroundRefresh ?? true
        if settings.region.uppercased() != "" {
            regionButton.setTitle(settings.region.uppercased(), for: .normal)
        } else {
            regionButton.setTitle("US", for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            
            launchCountryPicker()
            
        } else if indexPath.row == 4 {
            
            regionButton.setTitle(countryCodes[row].uppercased(), for: .normal)
            let ac : AboutController = storyboard!.instantiateViewController(withIdentifier: "AboutController") as! AboutController
            navigationController?.pushViewController(ac, animated: true)
            
        } else if indexPath.row == 5 {
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients(["wishlistplusapp@gmail.com"])
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
            
        }
        return
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.backBarButtonItem?.title = ""
        title = ""
        return
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //change country
        self.row = row
        regionButton.setTitle(countryCodes[row].uppercased(), for: .normal)
        settings.region = countryCodes[row]
        Helper.save(object: settings, key: "settings")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
}
