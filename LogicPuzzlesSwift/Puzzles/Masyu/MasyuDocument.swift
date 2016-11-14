//
//  MasyuDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class MasyuDocument: GameDocument<MasyuGameMove> {
    static var sharedInstance = MasyuDocument()
    var gameProgress: MasyuGameProgress {
        let result = MasyuGameProgress.query().fetch()!
        return result.count == 0 ? MasyuGameProgress() : (result[0] as! MasyuGameProgress)
    }
    var levelProgress: MasyuLevelProgress {
        let result = MasyuLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = MasyuLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! MasyuLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return MasyuMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "Masyu")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! MasyuGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: MasyuGameMove) {
        let game = game as! MasyuGame
        MasyuMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = MasyuMoveProgress()
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
        MasyuMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
