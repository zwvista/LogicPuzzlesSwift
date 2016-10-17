//
//  BridgesDocument.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class BridgesDocument {
    static var sharedInstance = BridgesDocument()
    private(set) var levels = [String: [String]]()
    var selectedLevelID: String!
    var gameProgress: BridgesGameProgress {
        let result = BridgesGameProgress.query().fetch()!
        return result.count == 0 ? BridgesGameProgress() : (result[0] as! BridgesGameProgress)
    }
    var levelProgress: BridgesLevelProgress {
        let result = BridgesLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = BridgesLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! BridgesLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return BridgesMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        let path = Bundle.main.path(forResource: "BridgesLevels", ofType: "xml")!
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
    
    func levelUpdated(game: BridgesGame) {
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func moveAdded(game: BridgesGame, move: BridgesGameMove) {
        BridgesMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = BridgesMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.rowFrom, rec.colFrom) = move.pFrom.unapply()
        (rec.rowTo, rec.colTo) = move.pTo.unapply()
        rec.commit()
    }
    
    func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    func clearGame() {
        BridgesMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
