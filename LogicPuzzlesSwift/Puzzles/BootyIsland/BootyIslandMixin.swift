//
//  BootyIslandMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BootyIslandMixin: GameMixin {
}

extension BootyIslandMixin {
    var gameDocumentBase: GameDocumentBase { return BootyIslandDocument.sharedInstance }
    var gameDocument: BootyIslandDocument { return BootyIslandDocument.sharedInstance }
}
