//
//  SkyscrapersMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol SkyscrapersMixin: GameMixin {
    var gameDocument: SkyscrapersDocument { get }
    var gameOptions: SkyscrapersGameProgress { get }
}

extension SkyscrapersMixin {
    var gameDocument: SkyscrapersDocument { return SkyscrapersDocument.sharedInstance }
    var gameOptions: SkyscrapersGameProgress { return gameDocument.gameProgress }
}
