//
//  CloudsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class CloudsDocument: GameDocument<CloudsGameMove> {
    static var sharedInstance = CloudsDocument()
    var gameProgress: CloudsGameProgress {
        let result = CloudsGameProgress.query().fetch()!
        return result.count == 0 ? CloudsGameProgress() : (result[0] as! CloudsGameProgress)
    }
    var levelProgress: CloudsLevelProgress {
        let result = CloudsLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = CloudsLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! CloudsLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return CloudsMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        super.init(forResource: "CloudsLevels")
        selectedLevelID = gameProgress.levelID
    }
    
    override func levelUpdated(game: AnyObject) {
        let game = game as! CloudsGame
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    override func moveAdded(game: AnyObject, move: CloudsGameMove) {
        let game = game as! CloudsGame
        CloudsMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = CloudsMoveProgress()
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
        CloudsMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
