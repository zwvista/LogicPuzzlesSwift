//
//  LineSweeperDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LineSweeperDocument: GameDocument<LineSweeperGameMove> {
    static var sharedInstance = LineSweeperDocument()
    var gameProgress: LineSweeperGameProgress {
        let result = LineSweeperGameProgress.query().fetch()!
        return result.count == 0 ? LineSweeperGameProgress() : (result[0] as! LineSweeperGameProgress)
    }
    var levelProgress: LineSweeperLevelProgress {
        let result = LineSweeperLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = LineSweeperLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! LineSweeperLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return LineSweeperMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "LineSweeper")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! LineSweeperGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: LineSweeperGameMove) {
        let game = game as! LineSweeperGame
        LineSweeperMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = LineSweeperMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.row, rec.col) = move.p.unapply()
        rec.objOrientation = move.objOrientation.rawValue
        rec.obj = move.obj.rawValue
        rec.commit()
    }
    
    override func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    override func clearGame() {
        LineSweeperMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
