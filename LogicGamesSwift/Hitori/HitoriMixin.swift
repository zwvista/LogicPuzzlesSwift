//
//  HitoriMixin.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol HitoriMixin {
    var gameDocument: HitoriDocument { get }
    var gameOptions: HitoriGameProgress { get }
    var soundManager: SoundManager { get }
}

extension HitoriMixin {
    var gameDocument: HitoriDocument { return HitoriDocument.sharedInstance }
    var gameOptions: HitoriGameProgress { return gameDocument.gameProgress }
    var soundManager: SoundManager { return SoundManager.sharedInstance }
}
