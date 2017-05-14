//
//  FenceSentinelsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol FenceSentinelsMixin: GameMixin {
}

extension FenceSentinelsMixin {
    var gameDocumentBase: GameDocumentBase { return FenceSentinelsDocument.sharedInstance }
    var gameDocument: FenceSentinelsDocument { return FenceSentinelsDocument.sharedInstance }
}
