//
//  BattleShipsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BattleShipsMixin: GameMixin {
}

extension BattleShipsMixin {
    var gameDocumentBase: GameDocumentBase { return BattleShipsDocument.sharedInstance }
    var gameDocument: BattleShipsDocument { return BattleShipsDocument.sharedInstance }
}
