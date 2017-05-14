//
//  AbstractPaintingMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol AbstractPaintingMixin: GameMixin {
}

extension AbstractPaintingMixin {
    var gameDocumentBase: GameDocumentBase { return AbstractPaintingDocument.sharedInstance }
    var gameDocument: AbstractPaintingDocument { return AbstractPaintingDocument.sharedInstance }
}
