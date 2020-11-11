//
//  HomeTables.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class HomeGameProgress: Object {
    dynamic var id: String = NSUUID().uuidString
    dynamic var gameName: String? = "LightenUp"
    dynamic var gameTitle: String? = "Lighten Up"
    dynamic var playMusic = true
    dynamic var playSound = true
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
