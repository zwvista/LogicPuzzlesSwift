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
    
    func updateMarkerOption(markerOption: Int) {
        lblMarkerOption.text = MarkerOptions.optionStrings[markerOption]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rec = options
        updateMarkerOption(markerOption: rec.markerOption)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rec = options
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: MarkerOptions.optionStrings, initialSelection: rec.markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            rec.markerOption = selectedIndex
            rec.commit()
            self.updateMarkerOption(markerOption: rec.markerOption)
        }, cancel: nil, origin: lblMarker)

    }

}
