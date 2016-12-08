//
//  LightenUpOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LightenUpOptionsViewController: OptionsViewController, LightenUpMixin {
    
    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    @IBOutlet weak var swNormalLightbulbsOnly: UISwitch!
    
    func updateMarkerOption() {
        lblMarkerOption.text = MarkerOptions.optionStrings[markerOption]
    }
    
    func updateNormalLightbulbsOnly() {
        swNormalLightbulbsOnly.isOn = normalLightbulbsOnly;
    }
    
    @IBAction func normalLightbulbsOnlyChanged(_ sender: AnyObject) {
        setNormalLightbulbsOnly(swNormalLightbulbsOnly.isOn)
        gameOptions.commit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
        updateNormalLightbulbsOnly()
    }

    override func onDefault() {
        setMarkerOption(MarkerOptions.noMarker.rawValue)
        setNormalLightbulbsOnly(false)
        gameOptions.commit()
        updateMarkerOption()
        updateNormalLightbulbsOnly()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: MarkerOptions.optionStrings, initialSelection: markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            self.setMarkerOption(selectedIndex)
            self.gameOptions.commit()
            self.updateMarkerOption()
        }, cancel: nil, origin: lblMarker)
    }

}
