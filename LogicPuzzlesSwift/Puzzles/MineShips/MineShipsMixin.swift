//
//  MineShipsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol MineShipsMixin: GameMixin {
}

extension MineShipsMixin {
    var gameDocumentBase: GameDocumentBase { return MineShipsDocument.sharedInstance }
    var gameDocument: MineShipsDocument { return MineShipsDocument.sharedInstance }
}
