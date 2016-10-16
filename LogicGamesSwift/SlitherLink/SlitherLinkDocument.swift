//
//  SlitherLinkDocument.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class SlitherLinkDocument {
    static var sharedInstance = SlitherLinkDocument()
    private(set) var levels = [String: [String]]()
    var selectedLevelID: String!
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
        let path = Bundle.main.path(forResource: "SlitherLinkLevels", ofType: "xml")!
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
    
    func levelUpdated(game: SlitherLinkGame) {
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func moveAdded(game: SlitherLinkGame, move: SlitherLinkGameMove) {
        SlitherLinkMoveProgress.query().where(withFormat: "levelID = %@ AND moveIndex >= %@", withParameters: [selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = SlitherLinkMoveProgress()
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        (rec.row, rec.col) = move.p.unapply()
        rec.objTypeAsString = move.objType.toString()
        rec.commit()
    }
    
    func resumGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    func clearGame() {
        SlitherLinkMoveProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch().removeAll()

        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
