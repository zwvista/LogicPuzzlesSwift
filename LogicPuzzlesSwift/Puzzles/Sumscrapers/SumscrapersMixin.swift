//
//  SumscrapersMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol SumscrapersMixin: GameMixin {
    var gameDocument: SumscrapersDocument { get }
    var gameOptions: GameProgress { get }
}

extension SumscrapersMixin {
    var gameDocument: SumscrapersDocument { return SumscrapersDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
}
