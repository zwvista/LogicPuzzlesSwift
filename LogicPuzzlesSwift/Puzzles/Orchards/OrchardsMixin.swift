//
//  OrchardsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol OrchardsMixin: GameMixin {
}

extension OrchardsMixin {
    var gameDocumentBase: GameDocumentBase { return OrchardsDocument.sharedInstance }
    var gameDocument: OrchardsDocument { return OrchardsDocument.sharedInstance }
}
