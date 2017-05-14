//
//  BoxItUpMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BoxItUpMixin: GameMixin {
}

extension BoxItUpMixin {
    var gameDocumentBase: GameDocumentBase { return BoxItUpDocument.sharedInstance }
    var gameDocument: BoxItUpDocument { return BoxItUpDocument.sharedInstance }
}
