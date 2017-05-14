//
//  SumscrapersMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol SumscrapersMixin: GameMixin {
    var gameOptions: GameProgress { get }
}

extension SumscrapersMixin {
    var gameDocumentBase: GameDocumentBase { return SumscrapersDocument.sharedInstance }
    var gameDocument: SumscrapersDocument { return SumscrapersDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
}
