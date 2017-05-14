//
//  SentinelsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol SentinelsMixin: GameMixin {
}

extension SentinelsMixin {
    var gameDocumentBase: GameDocumentBase { return SentinelsDocument.sharedInstance }
    var gameDocument: SentinelsDocument { return SentinelsDocument.sharedInstance }
}
