//
//  LogicGamesDocument.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LogicGamesDocument {
    static var sharedInstance = LogicGamesDocument()
    var gameOptions: LogicGamesProgress {
        let result = LogicGamesProgress.query().fetch()!
        return result.count == 0 ? LogicGamesProgress() : (result[0] as! LogicGamesProgress)
    }
}
