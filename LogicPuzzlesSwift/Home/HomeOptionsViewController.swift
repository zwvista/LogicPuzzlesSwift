//
//  GameOptionsViewController.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import RealmSwift

class HomeOptionsViewController: UITableViewController, HomeMixin {
    
    @IBOutlet weak var swPlayMusic: UISwitch!
    @IBOutlet weak var swPlaySound: UISwitch!
    let realm = try! Realm()
    func updatePlayMusic() {
        swPlayMusic.isOn = gameOptions.playMusic
    }
    
    func updatePlaySound() {
        swPlaySound.isOn = gameOptions.playSound
    }
    
    @IBAction func playMusicChanged(_ sender: Any) {
        try! realm.write {
            let rec = gameOptions
            rec.playMusic = swPlayMusic.isOn
            realm.add(rec, update: .all)
        }
        soundManager.playOrPauseMusic()
    }
    
    @IBAction func playSoundChanged(_ sender: Any) {
        try! realm.write {
            let rec = gameOptions
            rec.playSound = swPlaySound.isOn
            realm.add(rec, update: .all)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlayMusic()
        updatePlaySound()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    override var shouldAutorotate: Bool { false }
    
    @IBAction func onDefault(_ sender: Any) {
        let alertController = UIAlertController(title: "Default Options", message: "Do you really want to reset the options?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            try! self.realm.write {
                let rec = self.gameOptions
                rec.playMusic = true
                rec.playSound = true
                self.realm.add(rec, update: .all)
            }
            self.updatePlayMusic()
            self.soundManager.playOrPauseMusic()
            self.updatePlaySound()
        }
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
