//
//  LevelProgress.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import SharkORM

class LevelProgress: SRKObject {
    dynamic var levelID: String?
    dynamic var movesAsString: String?
    dynamic var moveIndex: NSNumber?
    
    override open class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["moveIndex" : 0]
    }
}

class GameProgress: SRKObject {
    dynamic var levelID: String?
    
    override open class func defaultValuesForEntity() -> [AnyHashable : Any]! {
        return ["levelID" : "level 1"]
    }
}
