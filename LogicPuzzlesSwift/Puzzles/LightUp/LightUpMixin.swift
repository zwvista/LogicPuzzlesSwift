//
//  LightUpMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LightUpMixin: GameMixin {
    var gameDocument: LightUpDocument { get }
    var gameOptions: LightUpGameProgress { get }
}

extension LightUpMixin {
    var gameDocument: LightUpDocument { return LightUpDocument.sharedInstance }
    var gameOptions: LightUpGameProgress { return gameDocument.gameProgress }
}
