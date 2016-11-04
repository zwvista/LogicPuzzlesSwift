//
//  HitoriMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol HitoriMixin: GameMixin {
    var gameDocument: HitoriDocument { get }
    var gameOptions: HitoriGameProgress { get }
}

extension HitoriMixin {
    var gameDocument: HitoriDocument { return HitoriDocument.sharedInstance }
    var gameOptions: HitoriGameProgress { return gameDocument.gameProgress }
}
