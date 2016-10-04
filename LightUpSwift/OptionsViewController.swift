//
//  OptionsViewController.swift
//  LightUpSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController {
    
    var options: GameProgress { return GameDocument.sharedInstance.gameProgress }

    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    @IBOutlet weak var swNormalLightbulbsOnly: UISwitch!
    
    func updateMarkerOption() {
        lblMarkerOption.text = MarkerOptions.optionStrings[options.markerOption]
    }
    
    @IBAction func normalLightbulbsOnlyChanged(_ sender: AnyObject) {
        let rec = options
        rec.normalLightbulbsOnly = swNormalLightbulbsOnly.isOn
        rec.commit()
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let rec = self.options
            rec.markerOption = MarkerOptions.noMarker.rawValue
            rec.normalLightbulbsOnly = false
            rec.commit()
            self.updateMarkerOption()
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rec = options
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: MarkerOptions.optionStrings, initialSelection: rec.markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            rec.markerOption = selectedIndex
            rec.commit()
            self.updateMarkerOption()
        }, cancel: nil, origin: lblMarker)
    }

}
