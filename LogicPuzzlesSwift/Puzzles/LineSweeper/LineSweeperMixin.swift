//
//  LineSweeperMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LineSweeperMixin: GameMixin {
}

extension LineSweeperMixin {
    var gameDocumentBase: GameDocumentBase { return LineSweeperDocument.sharedInstance }
    var gameDocument: LineSweeperDocument { return LineSweeperDocument.sharedInstance }
}
