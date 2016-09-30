//
//  GameDocument.swift
//  LightUpSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class GameDocument {
    static var sharedInstance = GameDocument()
    private(set) var levels = [String: [String]]()
    var selectedLevelID: String!
    var gameProgress: GameProgress {
        let result = GameProgress.query().fetch()!
        return result.count == 0 ? GameProgress() : (result[0] as! GameProgress)
    }
    var levelProgress: LevelProgress {
        let result = LevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = LevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! LevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return MoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        let path = Bundle.main.path(forResource: "Levels", ofType: "xml")!
        let xml = try! String(contentsOfFile: path)
        let doc = try! XMLDocument(string: xml)
        for elem in doc.root!.children {
            guard let key = elem.attr("id") else {continue}
            var arr = elem.stringValue.components(separatedBy: "\n")
            arr = Array(arr[2 ..< (arr.count - 2)])
            arr = arr.map { s in s.substring(to: s.index(before: s.endIndex)) }
            levels["Level " + key] = arr
        }
        
        selectedLevelID = gameProgress.levelID
    }
    
    func levelUpdated(game: Game) {
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func moveAdded(game: Game, move: GameMove) {
        MoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = MoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        rec.row = move.p.row
        rec.col = move.p.col
        rec.objTypeAsString = move.objType.toString()
        rec.commit()
    }
    
    func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    func clearGame() {
        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
        
        MoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()
    }
}
