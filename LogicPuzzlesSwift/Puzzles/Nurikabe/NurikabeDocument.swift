//
//  NurikabeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class NurikabeDocument: GameDocument<NurikabeGameMove> {
    static var sharedInstance = NurikabeDocument()
    var gameProgress: NurikabeGameProgress {
        let result = NurikabeGameProgress.query().fetch()!
        return result.count == 0 ? NurikabeGameProgress() : (result[0] as! NurikabeGameProgress)
    }
    var levelProgress: NurikabeLevelProgress {
        let result = NurikabeLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = NurikabeLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! NurikabeLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return NurikabeMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "NurikabeLevels")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! NurikabeGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: NurikabeGameMove) {
        let game = game as! NurikabeGame
        NurikabeMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = NurikabeMoveProgress()
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
        NurikabeMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
