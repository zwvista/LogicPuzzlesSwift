//
//  RoomsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol RoomsMixin: GameMixin {
}

extension RoomsMixin {
    var gameDocumentBase: GameDocumentBase { return RoomsDocument.sharedInstance }
    var gameDocument: RoomsDocument { return RoomsDocument.sharedInstance }
}
