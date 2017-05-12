//
//  HomeTables.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import SharkORM

class HomeGameProgress: SRKObject {
    dynamic var gameName: String?
    dynamic var gameTitle: String?
    dynamic var playMusic = true
    dynamic var playSound = true
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["gameName": "LightenUp", "playMusic": true, "playSound": true]
    }
}
