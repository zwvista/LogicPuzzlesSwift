//
//  MasyuMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol MasyuMixin: GameMixin {
    var gameDocument: MasyuDocument { get }
    var gameOptions: GameProgress { get }
}

extension MasyuMixin {
    var gameDocument: MasyuDocument { return MasyuDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
}
