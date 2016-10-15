//
//  BridgesMixin.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BridgesMixin {
    var gameDocument: BridgesDocument { get }
    var gameOptions: BridgesGameProgress { get }
    var soundManager: SoundManager { get }
}

extension BridgesMixin {
    var gameDocument: BridgesDocument { return BridgesDocument.sharedInstance }
    var gameOptions: BridgesGameProgress { return gameDocument.gameProgress }
    var soundManager: SoundManager { return SoundManager.sharedInstance }
}
