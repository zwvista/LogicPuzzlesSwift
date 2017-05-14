//
//  BoxItAroundMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BoxItAroundMixin: GameMixin {
}

extension BoxItAroundMixin {
    var gameDocumentBase: GameDocumentBase { return BoxItAroundDocument.sharedInstance }
    var gameDocument: BoxItAroundDocument { return BoxItAroundDocument.sharedInstance }
}
