//
//  MosaikOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MosaikOptionsViewController: OptionsViewController, MosaikMixin {
    
    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    
    func updateMarkerOption() {
        lblMarkerOption.text = MarkerOptions.optionStrings[markerOption]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
    }

    override func onDefault() {
        let rec = self.gameOptions
        setMarkerOption(MarkerOptions.noMarker.rawValue)
        rec.commit()
        self.updateMarkerOption()
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
