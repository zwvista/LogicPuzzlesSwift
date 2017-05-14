//
//  AbcMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol AbcMixin: GameMixin {
}

extension AbcMixin {
    var gameDocumentBase: GameDocumentBase { return AbcDocument.sharedInstance }
    var gameDocument: AbcDocument { return AbcDocument.sharedInstance }
}
