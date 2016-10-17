//
//  LightUpDocument.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LightUpDocument {
    static var sharedInstance = LightUpDocument()
    private(set) var levels = [String: [String]]()
    var selectedLevelID: String!
    var gameProgress: LightUpGameProgress {
        let result = LightUpGameProgress.query().fetch()!
        return result.count == 0 ? LightUpGameProgress() : (result[0] as! LightUpGameProgress)
    }
    var levelProgress: LightUpLevelProgress {
        let result = LightUpLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = LightUpLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! LightUpLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return LightUpMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        let path = Bundle.main.path(forResource: "LightUpLevels", ofType: "xml")!
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
    
    func levelUpdated(game: LightUpGame) {
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func moveAdded(game: LightUpGame, move: LightUpGameMove) {
        LightUpMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = LightUpMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.row, rec.col) = move.p.unapply()
        rec.objTypeAsString = move.objType.toString()
        rec.commit()
    }
    
    func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    func clearGame() {
        LightUpMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
