//
//  HitoriOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HitoriOptionsViewController: OptionsViewController, HitoriMixin {
    
    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    @IBOutlet weak var swNormalLightbulbsOnly: UISwitch!
    
    func updateMarkerOption() {
        lblMarkerOption.text = HitoriMarkerOptions.optionStrings[markerOption]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
    }

    override func onDefault() {
        setMarkerOption(HitoriMarkerOptions.noMarker.rawValue)
        gameOptions.commit()
        self.updateMarkerOption()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: HitoriMarkerOptions.optionStrings, initialSelection: markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            self.setMarkerOption(selectedIndex)
            self.gameOptions.commit()
            self.updateMarkerOption()
        }, cancel: nil, origin: lblMarker)
    }

}
