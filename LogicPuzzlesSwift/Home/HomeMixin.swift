//
//  HomeMixin.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol HomeMixin: SoundMixin {
}

extension HomeMixin {
    var gameDocument: HomeDocument { HomeDocument.sharedInstance }
    var gameOptions: HomeGameProgress { gameDocument.gameProgress }
}
