//
//  TentsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol TentsMixin: GameMixin {
}

extension TentsMixin {
    var gameDocumentBase: GameDocumentBase { return TentsDocument.sharedInstance }
    var gameDocument: TentsDocument { return TentsDocument.sharedInstance }
}
