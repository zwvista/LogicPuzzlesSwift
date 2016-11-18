//
//  LightenUpDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LightenUpDocument: GameDocument<LightenUpGameMove> {
    static var sharedInstance = LightenUpDocument()
    var gameProgress: LightenUpGameProgress {
        let result = LightenUpGameProgress.query().fetch()!
        return result.count == 0 ? LightenUpGameProgress() : (result[0] as! LightenUpGameProgress)
    }
    var levelProgress: LightenUpLevelProgress {
        let result = LightenUpLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = LightenUpLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! LightenUpLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return LightenUpMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "LightenUp")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! LightenUpGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: LightenUpGameMove) {
        let game = game as! LightenUpGame
        LightenUpMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = LightenUpMoveProgress()
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
        LightenUpMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
