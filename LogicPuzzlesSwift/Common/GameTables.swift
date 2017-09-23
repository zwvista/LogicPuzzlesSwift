//
//  AbcTables.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import SharkORM

class GameProgress: SRKObject {
    @objc dynamic var gameID: String?
    @objc dynamic var levelID: String?
    @objc dynamic var option1: String?
    @objc dynamic var option2: String?
    @objc dynamic var option3: String?
    @objc dynamic var option4: String?
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["levelID": "1"]
    }
}

class LevelProgress: SRKObject {
    @objc dynamic var gameID: String?
    @objc dynamic var levelID: String?
    @objc dynamic var moveIndex = 0
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}

class MoveProgress: SRKObject {
    @objc dynamic var gameID: String?
    @objc dynamic var levelID: String?
    @objc dynamic var moveIndex = 0
    @objc dynamic var row = 0
    @objc dynamic var col = 0
    @objc dynamic var row2 = 0
    @objc dynamic var col2 = 0
    @objc dynamic var intValue1 = 0
    @objc dynamic var intValue2 = 0
    @objc dynamic var strValue1: String?
    @objc dynamic var strValue2: String?
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}
