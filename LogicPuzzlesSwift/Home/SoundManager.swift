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
class SoundManager: NSObject, AVAudioPlayerDelegate {
    static var sharedInstance = SoundManager()
    var gameOptions: HomeGameProgress { return HomeDocument.sharedInstance.gameProgress }

    // https://stackoverflow.com/questions/58360765/swift-5-1-error-plugin-addinstanceforfactory-no-factory-registered-for-id-c
    var apMusic: AVAudioPlayer!
    // http://stackoverflow.com/questions/31405990/avaudioplayer-play-multiple-times-same-sound-without-interrupting
    var soundIDTap: SystemSoundID = 0
    var soundIDSolved: SystemSoundID = 0
    
    override init() {
        super.init()
        var url = NSURL(fileURLWithPath: Bundle.main.path(forResource: "tap", ofType: "wav")!)
        AudioServicesCreateSystemSoundID(url, &soundIDTap)
        url = NSURL(fileURLWithPath: Bundle.main.path(forResource: "solved", ofType: "wav")!)
        AudioServicesCreateSystemSoundID(url, &soundIDSolved)
        
        playCurrentMusic()
    }
    
    func playCurrentMusic() {
        let musicFiles = try! FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
            .filter{$0.starts(with: "music")}
        let index = Int(arc4random_uniform(UInt32(musicFiles.count)))
        let url = Bundle.main.url(forResource: musicFiles[index], withExtension: nil)!
        apMusic = try! AVAudioPlayer(contentsOf: url)
        apMusic.prepareToPlay()
        apMusic.delegate = self
        playOrPauseMusic()
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
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playCurrentMusic()
    }

}
