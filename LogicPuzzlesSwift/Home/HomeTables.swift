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
    @objc dynamic var gameName: String?
    @objc dynamic var gameTitle: String?
    @objc dynamic var playMusic = true
    @objc dynamic var playSound = true
    
    override class func defaultValuesForEntity() -> [String : Any] {
        ["gameName": "LightenUp", "gameTitle": "Lighten Up", "playMusic": true, "playSound": true]
    }
}
