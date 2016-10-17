//
//  LogicGamesMixin.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LogicGamesMixin {
    var gameDocument: LogicGamesDocument { get }
    var gameOptions: LogicGamesGameProgress { get }
    var soundManager: SoundManager { get }
}

extension LogicGamesMixin {
    var gameDocument: LogicGamesDocument { return LogicGamesDocument.sharedInstance }
    var gameOptions: LogicGamesGameProgress { return gameDocument.gameProgress }
    var soundManager: SoundManager { return SoundManager.sharedInstance }
}
