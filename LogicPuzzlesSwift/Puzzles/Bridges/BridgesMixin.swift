//
//  BridgesMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BridgesMixin: GameMixin {
    var gameOptions: GameProgress { get }
}

extension BridgesMixin {
    var gameDocumentBase: GameDocumentBase { return BridgesDocument.sharedInstance }
    var gameDocument: BridgesDocument { return BridgesDocument.sharedInstance }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
}
