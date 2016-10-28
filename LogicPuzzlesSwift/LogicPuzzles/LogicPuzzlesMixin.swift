//
//  LogicPuzzlesMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LogicPuzzlesMixin {
    var gameDocument: LogicPuzzlesDocument { get }
    var gameOptions: LogicPuzzlesGameProgress { get }
    var soundManager: SoundManager { get }
}

extension LogicPuzzlesMixin {
    var gameDocument: LogicPuzzlesDocument { return LogicPuzzlesDocument.sharedInstance }
    var gameOptions: LogicPuzzlesGameProgress { return gameDocument.gameProgress }
    var soundManager: SoundManager { return SoundManager.sharedInstance }
}
