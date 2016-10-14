//
//  LogicGamesTables.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import SharkORM

class LogicGamesProgress: SRKObject {
    dynamic var lastGame: String?
    dynamic var playMusic = true
    dynamic var playSound = true
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["lastGame": "LightUp", "playMusic": true, "playSound": true]
    }
}
