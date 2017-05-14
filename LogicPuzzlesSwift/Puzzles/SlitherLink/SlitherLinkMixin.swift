//
//  SlitherLinkMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol SlitherLinkMixin: GameMixin {
}

extension SlitherLinkMixin {
    var gameDocumentBase: GameDocumentBase { return SlitherLinkDocument.sharedInstance }
    var gameDocument: SlitherLinkDocument { return SlitherLinkDocument.sharedInstance }
}
