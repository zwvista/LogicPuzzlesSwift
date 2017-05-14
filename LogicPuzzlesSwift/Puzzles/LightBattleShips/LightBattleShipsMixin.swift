//
//  LightBattleShipsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LightBattleShipsMixin: GameMixin {
}

extension LightBattleShipsMixin {
    var gameDocumentBase: GameDocumentBase { return LightBattleShipsDocument.sharedInstance }
    var gameDocument: LightBattleShipsDocument { return LightBattleShipsDocument.sharedInstance }
}
