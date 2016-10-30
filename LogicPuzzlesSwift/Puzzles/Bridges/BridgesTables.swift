//
//  BridgesTables.swift
//  LogicPuzzlesSwift
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
    dynamic var rowFrom = 0
    dynamic var colFrom = 0
    dynamic var rowTo = 0
    dynamic var colTo = 0
    
    override class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex": 0]
    }
}
