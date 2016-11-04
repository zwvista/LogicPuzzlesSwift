//
//  BridgesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class BridgesDocument: GameDocument<BridgesGameMove> {
    static var sharedInstance = BridgesDocument()
    var gameProgress: BridgesGameProgress {
        let result = BridgesGameProgress.query().fetch()!
        return result.count == 0 ? BridgesGameProgress() : (result[0] as! BridgesGameProgress)
    }
    var levelProgress: BridgesLevelProgress {
        let result = BridgesLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = BridgesLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! BridgesLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return BridgesMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "BridgesLevels")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! BridgesGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: BridgesGameMove) {
        let game = game as! BridgesGame
        BridgesMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = BridgesMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.rowFrom, rec.colFrom) = move.pFrom.unapply()
        (rec.rowTo, rec.colTo) = move.pTo.unapply()
        rec.commit()
    }
    
    override func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    override func clearGame() {
        BridgesMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()
        
        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
