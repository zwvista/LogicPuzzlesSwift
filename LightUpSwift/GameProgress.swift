//
//  LevelProgress.swift
//  LightUpSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import SharkORM

class GameProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var useMarker = false
    
    override open class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["levelID" : "Level 1", "useMarker" : false]
    }
}

class LevelProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var moveIndex: NSNumber?
    
    override open class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex" : 0]
    }
}

class MoveProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var moveIndex: NSNumber?
    dynamic var row: NSNumber?
    dynamic var col: NSNumber?
    dynamic var objTypeAsString: NSString?
    
    override open class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex" : 0]
    }
}
