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
    var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    @IBOutlet weak var swNormalLightbulbsOnly: UISwitch!
    @IBOutlet weak var swPlayMusic: UISwitch!
    @IBOutlet weak var swPlaySound: UISwitch!
    
    func updateMarkerOption() {
        lblMarkerOption.text = MarkerOptions.optionStrings[options.markerOption]
    }
    
    func updateNormalLightbulbsOnly() {
        swNormalLightbulbsOnly.isOn = options.normalLightbulbsOnly;
    }
    
    func updatePlayMusic() {
        swPlayMusic.isOn = options.playMusic;
    }
    
    func updatePlaySound() {
        swPlaySound.isOn = options.playSound;
    }
    
    @IBAction func normalLightbulbsOnlyChanged(_ sender: AnyObject) {
        let rec = options
        rec.normalLightbulbsOnly = swNormalLightbulbsOnly.isOn
        rec.commit()
    }
    
    @IBAction func playMusicChanged(_ sender: AnyObject) {
        let rec = options
        rec.playMusic = swPlayMusic.isOn
        rec.commit()
        appDelegate.playOrPauseMusic()
    }
    
    @IBAction func playSoundChanged(_ sender: AnyObject) {
        let rec = options
        rec.playSound = swPlaySound.isOn
        rec.commit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkerOption()
        updateNormalLightbulbsOnly()
        updatePlayMusic()
        updatePlaySound()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func onDefault(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Default Options", message: "Do you really want to reset the options?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            let rec = self.options
            rec.markerOption = MarkerOptions.noMarker.rawValue
            rec.normalLightbulbsOnly = false
            rec.commit()
            self.updateMarkerOption()
            self.updateNormalLightbulbsOnly()
            self.updatePlayMusic()
            self.updatePlaySound()
        }
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        let rec = options
        ActionSheetStringPicker.show(withTitle: "Marker Options", rows: MarkerOptions.optionStrings, initialSelection: rec.markerOption, doneBlock: { (picker, selectedIndex, selectedValue) in
            rec.markerOption = selectedIndex
            rec.commit()
            self.updateMarkerOption()
        }, cancel: nil, origin: lblMarker)
    }

}
