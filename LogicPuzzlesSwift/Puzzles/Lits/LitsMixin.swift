//
//  LitsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LitsMixin: GameMixin {
}

extension LitsMixin {
    var gameDocumentBase: GameDocumentBase { return LitsDocument.sharedInstance }
    var gameDocument: LitsDocument { return LitsDocument.sharedInstance }
}
