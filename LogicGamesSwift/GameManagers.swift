//
//  GameManagers.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol GameManagers {
    var documentManager: DocumentManager { get }
    var gameOptions: GameProgress { get }
    var soundManager: SoundManager { get }
}

extension GameManagers {
    var documentManager: DocumentManager { return DocumentManager.sharedInstance }
    var gameOptions: GameProgress { return documentManager.gameProgress }
    var soundManager: SoundManager { return SoundManager.sharedInstance }
}
