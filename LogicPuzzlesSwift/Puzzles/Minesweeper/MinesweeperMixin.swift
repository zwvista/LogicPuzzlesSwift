//
//  MinesweeperMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol MinesweeperMixin: GameMixin {
}

extension MinesweeperMixin {
    var gameDocumentBase: GameDocumentBase { return MinesweeperDocument.sharedInstance }
    var gameDocument: MinesweeperDocument { return MinesweeperDocument.sharedInstance }
}
