//
//  DominoMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol DominoMixin: GameMixin {
}

extension DominoMixin {
    var gameDocumentBase: GameDocumentBase { return DominoDocument.sharedInstance }
    var gameDocument: DominoDocument { return DominoDocument.sharedInstance }
}
