//
//  LogicPuzzlesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LogicPuzzlesDocument {
    static var sharedInstance = LogicPuzzlesDocument()
    var gameProgress: LogicPuzzlesGameProgress {
        let result = LogicPuzzlesGameProgress.query().fetch()!
        return result.count == 0 ? LogicPuzzlesGameProgress() : (result[0] as! LogicPuzzlesGameProgress)
    }
    
    func resumeGame(gameName: String) {
        let rec = gameProgress
        rec.gameName = gameName
        rec.commit()
    }

}
