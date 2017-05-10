//
//  BattleShipsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BattleShipsMixin: GameMixin {
    var gameDocument: BattleShipsDocument { get }
    var gameOptions: GameProgress { get }
    var markerOption: Int { get }
    func setMarkerOption(rec: GameProgress, newValue: Int)
    var allowedObjectsOnly: Bool { get }
    func setAllowedObjectsOnly(rec: GameProgress, newValue: Bool)
}

extension BattleShipsMixin {
    var gameDocument: BattleShipsDocument { return BattleShipsDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
    var markerOption: Int { return gameOptions.option1?.toInt() ?? 0 }
    func setMarkerOption(rec: GameProgress, newValue: Int) { rec.option1 = newValue.description }
    var allowedObjectsOnly: Bool { return gameOptions.option2?.toBool() ?? false }
    func setAllowedObjectsOnly(rec: GameProgress, newValue: Bool) { rec.option2 = newValue.description }
}
