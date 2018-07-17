//
//  AbcTables.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import SharkORM

@objcMembers
class GameProgress: SRKObject {
    dynamic var gameID: String?
    dynamic var levelID: String?
    dynamic var option1: String?
    dynamic var option2: String?
    dynamic var option3: String?
    dynamic var option4: String?
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["levelID": "1"]
    }
}

@objcMembers
class LevelProgress: SRKObject {
    dynamic var gameID: String?
    dynamic var levelID: String?
    dynamic var moveIndex = 0
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}

@objcMembers
class MoveProgress: SRKObject {
    dynamic var gameID: String?
    dynamic var levelID: String?
    dynamic var moveIndex = 0
    dynamic var row = 0
    dynamic var col = 0
    dynamic var row2 = 0
    dynamic var col2 = 0
    dynamic var intValue1 = 0
    dynamic var intValue2 = 0
    dynamic var strValue1: String?
    dynamic var strValue2: String?
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}
