//
//  GameMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
protocol SoundMixin {
}

extension SoundMixin {
    var soundManager: SoundManager { return SoundManager.sharedInstance }
}

protocol GameMixin: SoundMixin {
    var gameDocumentBase: GameDocumentBase { get }
}

extension GameMixin {
    var gameOptions: GameProgress { return gameDocumentBase.gameProgress }
    var markerOption: Int { return gameOptions.option1?.toInt() ?? 0 }
    func setMarkerOption(rec: GameProgress, newValue: Int) { rec.option1 = newValue.description }
    var allowedObjectsOnly: Bool { return gameOptions.option2?.toBool() ?? false }
    func setAllowedObjectsOnly(rec: GameProgress, newValue: Bool) { rec.option2 = newValue.description }
}
