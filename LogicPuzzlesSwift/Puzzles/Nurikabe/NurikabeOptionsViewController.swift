//
//  NurikabeOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NurikabeOptionsViewController: OptionsViewController, NurikabeMixin {
    
    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    @IBOutlet weak var swNormalLightbulbsOnly: UISwitch!
    
    func updateMarkerOption() {
        lblMarkerOption.text = NurikabeMarkerOptions.optionStrings[gameOptions.markerOption]
    }
    
    func updateNormalLightbulbsOnly() {
        swNormalLightbulbsOnly.isOn = gameOptions.normalLightbulbsOnly;
    }
    
    @IBAction func normalLightbulbsOnlyChanged(_ sender: AnyObject) {
        let rec = gameOptions
        rec.normalLightbulbsOnly = swNormalLightbulbsOnly.isOn
        rec.commit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
        updateNormalLightbulbsOnly()
    }

    override func onDefault() {
        let rec = self.gameOptions
        rec.markerOption = NurikabeMarkerOptions.noMarker.rawValue
        rec.normalLightbulbsOnly = false
        rec.commit()
        self.updateMarkerOption()
        self.updateNormalLightbulbsOnly()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        let rec = gameOptions
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: NurikabeMarkerOptions.optionStrings, initialSelection: rec.markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            rec.markerOption = selectedIndex
            rec.commit()
            self.updateMarkerOption()
        }, cancel: nil, origin: lblMarker)
    }

}
