//
//  HitoriDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class HitoriDocument: GameDocument<HitoriGameMove> {
    static var sharedInstance = HitoriDocument()
    var gameProgress: HitoriGameProgress {
        let result = HitoriGameProgress.query().fetch()!
        return result.count == 0 ? HitoriGameProgress() : (result[0] as! HitoriGameProgress)
    }
    var levelProgress: HitoriLevelProgress {
        let result = HitoriLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = HitoriLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! HitoriLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return HitoriMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "HitoriLevels")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! HitoriGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: HitoriGameMove) {
        let game = game as! HitoriGame
        HitoriMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = HitoriMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.row, rec.col) = move.p.unapply()
        rec.obj = move.obj.rawValue
        rec.commit()
    }
    
    override func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    override func clearGame() {
        HitoriMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
