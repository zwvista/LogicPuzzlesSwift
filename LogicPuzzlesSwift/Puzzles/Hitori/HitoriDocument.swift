//
//  HitoriDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class HitoriDocument {
    static var sharedInstance = HitoriDocument()
    private(set) var levels = [String: [String]]()
    var selectedLevelID: String!
    var gameProgress: HitoriGameProgress {
        let result = HitoriGameProgress.query().fetch()!
        return result.count == 0 ? HitoriGameProgress() : (result[0] as! HitoriGameProgress)
    }
    var levelProgress: HitoriLevelProgress {
        let result = HitoriLevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = HitoriLevelProgress()
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! HitoriLevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return HitoriMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).order(by: "moveIndex").fetch()!
    }

    init() {
        let path = Bundle.main.path(forResource: "HitoriLevels", ofType: "xml")!
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
    
    func levelUpdated(game: HitoriGame) {
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func moveAdded(game: HitoriGame, move: HitoriGameMove) {
        HitoriMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = HitoriMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.row, rec.col) = move.p.unapply()
        rec.obj = move.obj.rawValue
        rec.commit()
    }
    
    func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    func clearGame() {
        HitoriMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
