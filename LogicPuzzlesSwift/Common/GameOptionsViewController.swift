//
//  GameOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import RealmSwift

class GameOptionsViewController: UITableViewController {
    
    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    @IBOutlet weak var swAllowedObjectsOnly: UISwitch!

    override var prefersStatusBarHidden: Bool { true }
    
    override var shouldAutorotate: Bool { false }
    
    private var gameDocument: GameDocumentBase { getGameDocument() }
    func getGameDocument() -> GameDocumentBase! { nil }
    let realm = try! Realm()
    var gameOptions: GameProgress { gameDocument.gameProgress }
    var markerOption: Int { gameOptions.option1?.toInt() ?? 0 }
    func setMarkerOption(rec: GameProgress, newValue: Int) { rec.option1 = newValue.description }
    var allowedObjectsOnly: Bool { gameOptions.option2?.toBool() ?? false }
    func setAllowedObjectsOnly(rec: GameProgress, newValue: Bool) { rec.option2 = newValue.description }
    
    // http://stackoverflow.com/questions/14111572/how-to-use-single-storyboard-uiviewcontroller-for-multiple-subclass
    override func awakeFromNib() {
        object_setClass(self, NSClassFromString("LogicPuzzlesSwift.\(currentGameName)OptionsViewController").self!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
        updateAllowedObjectsOnly()
    }
    
    @IBAction func allowedObjectsOnlyChanged(_ sender: Any) {
        let rec = gameOptions
        setAllowedObjectsOnly(rec: rec, newValue: swAllowedObjectsOnly.isOn)
        try! realm.write {
            realm.add(rec, update: .all)
        }
    }
    
    @IBAction func onDefault(_ sender: Any) {
        let alertController = UIAlertController(title: "Default Options", message: "Do you really want to reset the options?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.onDefault()
        }
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func onDefault() {
        let rec = gameOptions
        setMarkerOption(rec: rec, newValue: MarkerOptions.noMarker.rawValue)
        setAllowedObjectsOnly(rec: rec, newValue: false)
        try! realm.write {
            realm.add(rec, update: .all)
        }
        updateMarkerOption()
        updateAllowedObjectsOnly()
    }
    
    func updateMarkerOption() {
        lblMarkerOption.text = MarkerOptions.optionStrings[markerOption]
    }
    
    func updateAllowedObjectsOnly() {
        swAllowedObjectsOnly.isOn = allowedObjectsOnly
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else {return}
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: MarkerOptions.optionStrings, initialSelection: markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            let rec = self.gameOptions
            self.setMarkerOption(rec: rec, newValue: selectedIndex)
            try! self.realm.write {
                self.realm.add(rec, update: .all)
            }
            self.updateMarkerOption()
        } , cancel: nil, origin: lblMarker)
    }

    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
