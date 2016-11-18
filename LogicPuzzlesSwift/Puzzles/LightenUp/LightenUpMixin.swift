//
//  LightenUpMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LightenUpMixin: GameMixin {
    var gameDocument: LightenUpDocument { get }
    var gameOptions: LightenUpGameProgress { get }
}

extension LightenUpMixin {
    var gameDocument: LightenUpDocument { return LightenUpDocument.sharedInstance }
    var gameOptions: LightenUpGameProgress { return gameDocument.gameProgress }
}
