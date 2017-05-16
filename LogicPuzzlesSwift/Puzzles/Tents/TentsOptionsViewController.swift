//
//  TentsOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TentsOptionsViewController: GameOptionsViewController {

    var gameDocument: TentsDocument { return TentsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return TentsDocument.sharedInstance }
    
    func updateMarkerOption() {
        lblMarkerOption.text = MarkerOptions.optionStrings[markerOption]
    }
    
    func updateAllowedObjectsOnly() {
        swAllowedObjectsOnly.isOn = allowedObjectsOnly
    }
    
    override func allowedObjectsOnlyChanged(_ sender: Any) {
        let rec = gameOptions
        setAllowedObjectsOnly(rec: rec, newValue: swAllowedObjectsOnly.isOn)
        rec.commit()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
        updateAllowedObjectsOnly()
    }
    
    override func onDefault() {
        let rec = gameOptions
        setMarkerOption(rec: rec, newValue: MarkerOptions.noMarker.rawValue)
        setAllowedObjectsOnly(rec: rec, newValue: false)
        rec.commit()
        updateMarkerOption()
        updateAllowedObjectsOnly()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: MarkerOptions.optionStrings, initialSelection: markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            let rec = self.gameOptions
            self.setMarkerOption(rec: rec, newValue: selectedIndex)
            rec.commit()
            self.updateMarkerOption()
        }, cancel: nil, origin: lblMarker)
    }
}
