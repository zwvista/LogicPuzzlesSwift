//
//  AbcDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class AbcDocument: GameDocument<AbcGameMove> {
    static var sharedInstance = AbcDocument()
    var gameProgress: AbcGameProgress {
        let result = AbcGameProgress.query().fetch()!
        return result.count == 0 ? AbcGameProgress() : (result[0] as! AbcGameProgress)
    }
    var levelProgress: AbcLevelProgress {
        let result = AbcLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = AbcLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! AbcLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return AbcMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "Abc")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! AbcGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: AbcGameMove) {
        let game = game as! AbcGame
        AbcMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = AbcMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.row, rec.col) = move.p.unapply()
        rec.obj = String(move.obj)
        rec.commit()
    }
    
    override func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    override func clearGame() {
        AbcMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
