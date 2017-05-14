//
//  TatamiMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol TatamiMixin: GameMixin {
}

extension TatamiMixin {
    var gameDocumentBase: GameDocumentBase { return TatamiDocument.sharedInstance }
    var gameDocument: TatamiDocument { return TatamiDocument.sharedInstance }
}
