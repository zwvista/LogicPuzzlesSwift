//
//  BoxItAroundMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BoxItAroundMixin: GameMixin {
    var gameDocument: BoxItAroundDocument { get }
    var gameOptions: GameProgress { get }
    var markerOption: Int { get }
    func setMarkerOption(rec: GameProgress, newValue: Int)
}

extension BoxItAroundMixin {
    var gameDocument: BoxItAroundDocument { return BoxItAroundDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
    var markerOption: Int { return gameOptions.option1?.toInt() ?? 0 }
    func setMarkerOption(rec: GameProgress, newValue: Int) { rec.option1 = newValue.description }
}
