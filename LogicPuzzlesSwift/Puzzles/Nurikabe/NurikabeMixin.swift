//
//  NurikabeMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol NurikabeMixin: GameMixin {
}

extension NurikabeMixin {
    var gameDocumentBase: GameDocumentBase { return NurikabeDocument.sharedInstance }
    var gameDocument: NurikabeDocument { return NurikabeDocument.sharedInstance }
}
