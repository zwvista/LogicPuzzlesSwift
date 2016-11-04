//
//  LightUpDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LightUpDocument: GameDocument<LightUpGameMove> {
    static var sharedInstance = LightUpDocument()
    var gameProgress: LightUpGameProgress {
        let result = LightUpGameProgress.query().fetch()!
        return result.count == 0 ? LightUpGameProgress() : (result[0] as! LightUpGameProgress)
    }
    var levelProgress: LightUpLevelProgress {
        let result = LightUpLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = LightUpLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! LightUpLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return LightUpMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "LightUpLevels")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! LightUpGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: LightUpGameMove) {
        let game = game as! LightUpGame
        LightUpMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = LightUpMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.row, rec.col) = move.p.unapply()
        rec.objTypeAsString = move.objType.toString()
        rec.commit()
    }
    
    override func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    override func clearGame() {
        LightUpMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
