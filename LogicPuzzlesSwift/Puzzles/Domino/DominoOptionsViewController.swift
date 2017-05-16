//
//  DominoOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DominoOptionsViewController: GameOptionsViewController {

    var gameDocument: DominoDocument { return DominoDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return DominoDocument.sharedInstance }
    
    func updateMarkerOption() {
        lblMarkerOption.text = MarkerOptions.optionStrings[markerOption]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
    }
    
    override func onDefault() {
        let rec = gameOptions
        setMarkerOption(rec: rec, newValue: MarkerOptions.noMarker.rawValue)
        rec.commit()
        updateMarkerOption()
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
