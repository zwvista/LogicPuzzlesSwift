//
//  CloudsOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CloudsOptionsViewController: OptionsViewController, CloudsMixin {
    
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
    
    override func onDefault() {
        let rec = self.gameOptions
        rec.markerOption = CloudsMarkerOptions.noMarker.rawValue
        rec.commit()
        self.updateMarkerOption()
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
