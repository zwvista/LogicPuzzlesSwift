//
//  OptionsViewController.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HomeOptionsViewController: UITableViewController, HomeMixin {
    
    @IBOutlet weak var swPlayMusic: UISwitch!
    @IBOutlet weak var swPlaySound: UISwitch!
    func updatePlayMusic() {
        swPlayMusic.isOn = gameOptions.playMusic;
    }
    
    func updatePlaySound() {
        swPlaySound.isOn = gameOptions.playSound;
    }
    
    @IBAction func playMusicChanged(_ sender: AnyObject) {
        let rec = gameOptions
        rec.playMusic = swPlayMusic.isOn
        rec.commit()
        soundManager.playOrPauseMusic()
    }
    
    @IBAction func playSoundChanged(_ sender: AnyObject) {
        let rec = gameOptions
        rec.playSound = swPlaySound.isOn
        rec.commit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let rec = self.gameOptions
            rec.playMusic = true
            rec.playSound = true
            rec.commit()
            self.updatePlayMusic()
            self.soundManager.playOrPauseMusic()
            self.updatePlaySound()
        }
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit called: HomeOptionsViewController")
    }
}
