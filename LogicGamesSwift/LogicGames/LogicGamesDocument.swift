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
    var gameProgress: LogicGamesGameProgress {
        let result = LogicGamesGameProgress.query().fetch()!
        return result.count == 0 ? LogicGamesGameProgress() : (result[0] as! LogicGamesGameProgress)
    }
    
    func resumeGame(gameName: String) {
        let rec = gameProgress
        rec.gameName = gameName
        rec.commit()
    }

}
