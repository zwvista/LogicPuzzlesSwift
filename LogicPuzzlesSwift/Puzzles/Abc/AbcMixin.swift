//
//  AbcMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol AbcMixin: GameMixin {
    var gameDocument: AbcDocument { get }
    var gameOptions: GameProgress { get }
    var markerOption: Int { get }
    // cannot use property here due to compiler bug
    func setMarkerOption(_ newValue: Int)
}

extension AbcMixin {
    var gameDocument: AbcDocument { return AbcDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
    var markerOption: Int { return gameOptions.option1?.toInt() ?? 0 }
    func setMarkerOption(_ newValue: Int) { gameOptions.option1 = newValue.description }
}
