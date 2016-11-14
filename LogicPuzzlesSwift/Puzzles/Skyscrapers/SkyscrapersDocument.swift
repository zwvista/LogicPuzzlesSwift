//
//  SkyscrapersDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class SkyscrapersDocument: GameDocument<SkyscrapersGameMove> {
    static var sharedInstance = SkyscrapersDocument()
    var gameProgress: SkyscrapersGameProgress {
        let result = SkyscrapersGameProgress.query().fetch()!
        return result.count == 0 ? SkyscrapersGameProgress() : (result[0] as! SkyscrapersGameProgress)
    }
    var levelProgress: SkyscrapersLevelProgress {
        let result = SkyscrapersLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = SkyscrapersLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! SkyscrapersLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return SkyscrapersMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "Skyscrapers")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! SkyscrapersGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: SkyscrapersGameMove) {
        let game = game as! SkyscrapersGame
        SkyscrapersMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = SkyscrapersMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.row, rec.col) = move.p.unapply()
        rec.obj = move.obj
        rec.commit()
    }
    
    override func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    override func clearGame() {
        SkyscrapersMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
