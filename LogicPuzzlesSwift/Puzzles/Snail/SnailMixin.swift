//
//  SnailMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol SnailMixin: GameMixin {
}

extension SnailMixin {
    var gameDocumentBase: GameDocumentBase { return SnailDocument.sharedInstance }
    var gameDocument: SnailDocument { return SnailDocument.sharedInstance }
}
