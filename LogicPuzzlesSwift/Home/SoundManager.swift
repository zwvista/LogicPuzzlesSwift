//
//  SoundManager.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import AVFoundation

// http://stackoverflow.com/questions/24043904/creating-and-playing-a-sound-in-swift
class SoundManager {
    static var sharedInstance = SoundManager()
    var gameOptions: HomeGameProgress { return HomeDocument.sharedInstance.gameProgress }

    // Grab the path, make sure to add it to your project!
    var apMusic = AVAudioPlayer()
    // http://stackoverflow.com/questions/31405990/avaudioplayer-play-multiple-times-same-sound-without-interrupting
    var soundIDTap: SystemSoundID = 0
    var soundIDSolved: SystemSoundID = 0
    
    init() {
        var url = NSURL(fileURLWithPath: Bundle.main.path(forResource: "music", ofType: "wav")!)
        apMusic = try! AVAudioPlayer(contentsOf: url as URL)
        apMusic.numberOfLoops = -1
        apMusic.prepareToPlay()
        playOrPauseMusic()
        
        url = NSURL(fileURLWithPath: Bundle.main.path(forResource: "tap", ofType: "wav")!)
        AudioServicesCreateSystemSoundID(url, &soundIDTap)
        url = NSURL(fileURLWithPath: Bundle.main.path(forResource: "solved", ofType: "wav")!)
        AudioServicesCreateSystemSoundID(url, &soundIDSolved)
    }
    
    func playOrPauseMusic() {
        if gameOptions.playMusic {
            apMusic.play()
        } else {
            apMusic.pause()
        }
    }
    
    private func playSound(soundID: SystemSoundID) {
        if gameOptions.playSound {
            if #available(iOS 9.0, *) {
                AudioServicesPlaySystemSoundWithCompletion(soundID, nil)
            } else {
                AudioServicesPlaySystemSound(soundID)
            }
        }
    }
    
    public func playSoundTap() {
        playSound(soundID: soundIDTap)
    }
    
    public func playSoundSolved() {
        playSound(soundID: soundIDSolved)
    }

}
