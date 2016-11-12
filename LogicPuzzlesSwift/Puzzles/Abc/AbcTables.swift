//
//  AbcTables.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import SharkORM

class AbcGameProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var markerOption = 0
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["levelID": "Level 1", "markerOption": 0]
    }
}

class AbcLevelProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var moveIndex = 0
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}

class AbcMoveProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var moveIndex = 0
    dynamic var row = 0
    dynamic var col = 0
    dynamic var obj = " "
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}
