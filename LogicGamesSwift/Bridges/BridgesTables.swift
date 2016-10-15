//
//  BridgesTables.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import SharkORM

class BridgesGameProgress: SRKObject {
    dynamic var levelID: String?
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["levelID": "Level 1"]
    }
}

class BridgesLevelProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var moveIndex = 0
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}

class BridgesMoveProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var moveIndex = 0
    dynamic var row1 = 0
    dynamic var col1 = 0
    dynamic var row2 = 0
    dynamic var col2 = 0
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}
