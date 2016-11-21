//
//  GameDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class GameDocument<G: GameBase, GM> {
    private(set) var levels = [String: [String]]()
    var selectedLevelID: String!
    
    var gameProgress: GameProgress {
        let result = GameProgress.query().where(withFormat: "gameID = %@", withParameters: [G.gameID]).fetch()!
        if result.count == 0 {
            let rec = GameProgress()
            rec.gameID = G.gameID
            return rec
        } else {
            return result[0] as! GameProgress
        }
    }
    var levelProgress: LevelProgress {
        let result = LevelProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [G.gameID, selectedLevelID]).fetch()!
        if result.count == 0 {
            let rec = LevelProgress()
            rec.gameID = G.gameID
            rec.levelID = selectedLevelID
            return rec
        } else {
            return result[0] as! LevelProgress
        }
    }
    var moveProgress: SRKResultSet {
        return MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [G.gameID, selectedLevelID]).order(by: "moveIndex").fetch()!
    }
    
    init() {
        let path = Bundle.main.path(forResource: G.gameID, ofType: "xml")!
        let xml = try! String(contentsOfFile: path)
        let doc = try! XMLDocument(string: xml)
        for elem in doc.root!.children {
            guard let key = elem.attr("id") else {continue}
            var arr = elem.stringValue.components(separatedBy: "\n")
            arr = Array(arr[2..<(arr.count - 2)])
            arr = arr.map { s in s.substring(to: s.index(before: s.endIndex)) }
            levels["Level " + key] = arr
        }
        selectedLevelID = gameProgress.levelID
    }
    
    func levelUpdated(game: AnyObject) {
        let game = game as! G
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func moveAdded(game: AnyObject, move: GM) {
        let game = game as! G
        GameProgress.query().where(withFormat: "gameID = %@ AND levelID = %@ AND moveIndex >= %@", withParameters: [G.gameID, selectedLevelID, game.moveIndex]).fetch().removeAll()
        
        let rec = MoveProgress()
        rec.gameID = G.gameID
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        saveMove(move, to: rec)
        rec.commit()
    }
    
    func saveMove(_ move: GM, to rec: MoveProgress) {}
    
    func loadMove(from rec: MoveProgress) -> GM? {return nil}
    
    func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    func clearGame() {
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [G.gameID, selectedLevelID]).fetch().removeAll()
        
        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
}
