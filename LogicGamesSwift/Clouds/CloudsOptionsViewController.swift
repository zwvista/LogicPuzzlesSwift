//
//  CloudsOptionsViewController.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CloudsOptionsViewController: UITableViewController, CloudsMixin {
    
    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    @IBOutlet weak var swNormalLightbulbsOnly: UISwitch!
    
    func updateMarkerOption() {
        lblMarkerOption.text = CloudsMarkerOptions.optionStrings[gameOptions.markerOption]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func onDefault(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Default Options", message: "Do you really want to reset the options?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            let rec = self.gameOptions
            rec.markerOption = CloudsMarkerOptions.noMarker.rawValue
            rec.commit()
            self.updateMarkerOption()
        }
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        let rec = gameOptions
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: CloudsMarkerOptions.optionStrings, initialSelection: rec.markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            rec.markerOption = selectedIndex
            rec.commit()
            self.updateMarkerOption()
        }, cancel: nil, origin: lblMarker)
    }

}
