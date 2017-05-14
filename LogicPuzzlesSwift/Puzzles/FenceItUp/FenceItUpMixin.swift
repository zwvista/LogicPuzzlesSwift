//
//  FenceItUpMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol FenceItUpMixin: GameMixin {
}

extension FenceItUpMixin {
    var gameDocumentBase: GameDocumentBase { return FenceItUpDocument.sharedInstance }
    var gameDocument: FenceItUpDocument { return FenceItUpDocument.sharedInstance }
}
