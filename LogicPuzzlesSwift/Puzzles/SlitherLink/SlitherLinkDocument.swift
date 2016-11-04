//
//  SlitherLinkDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class SlitherLinkDocument: GameDocument<SlitherLinkGameMove> {
    static var sharedInstance = SlitherLinkDocument()
    var gameProgress: SlitherLinkGameProgress {
        let result = SlitherLinkGameProgress.query().fetch()!
        return result.count == 0 ? SlitherLinkGameProgress() : (result[0] as! SlitherLinkGameProgress)
    }
    var levelProgress: SlitherLinkLevelProgress {
        let result = SlitherLinkLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = SlitherLinkLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! SlitherLinkLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return SlitherLinkMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "SlitherLinkLevels")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! SlitherLinkGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: SlitherLinkGameMove) {
        let game = game as! SlitherLinkGame
        SlitherLinkMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = SlitherLinkMoveProgress()
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
        SlitherLinkMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
