//
//  LightenUpMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LightenUpMixin: GameMixin {
    var gameDocument: LightenUpDocument { get }
    var gameOptions: GameProgress { get }
    var markerOption: Int { get }
    // cannot use property here due to compiler bug
    func setMarkerOption(_ newValue: Int)
    var normalLightbulbsOnly: Bool { get }
    // cannot use property here due to compiler bug
    func setNormalLightbulbsOnly(_ newValue: Bool)
}

extension LightenUpMixin {
    var gameDocument: LightenUpDocument { return LightenUpDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
    var markerOption: Int { return gameOptions.option1?.toInt() ?? 0 }
    func setMarkerOption(_ newValue: Int) { gameOptions.option1 = newValue.description }
    var normalLightbulbsOnly: Bool { return gameOptions.option2?.toBool() ?? false }
    func setNormalLightbulbsOnly(_ newValue: Bool) { gameOptions.option2 = newValue.description }
}
