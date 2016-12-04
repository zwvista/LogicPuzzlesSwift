//
//  LoopyMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LoopyMixin: GameMixin {
    var gameDocument: LoopyDocument { get }
    var gameOptions: GameProgress { get }
}

extension LoopyMixin {
    var gameDocument: LoopyDocument { return LoopyDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
}
