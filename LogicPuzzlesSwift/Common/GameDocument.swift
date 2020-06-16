//
//  GameDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM
import Fuzi

struct GameLevel {
    var id: String
    var layout: [String]
    var settings: [String: String]
}

protocol GameDocumentBase: class {
    var gameProgress: GameProgress { get }
    var levelProgress: LevelProgress { get }
    var moveProgress: SRKResultSet { get }
    var levels: [GameLevel] { get }
    var help: [String] { get }
    var selectedLevelID: String! { get set }
    func resumeGame()
    func clearGame()
    var levelProgressSolution: LevelProgress { get }
    func saveSolution(game: AnyObject)
    func loadSolution()
    func deleteSolution()
    func resetAllLevels()
}

class GameDocument<GM>: GameDocumentBase {
    private(set) var levels = [GameLevel]()
    private(set) var help = [String]()
    var selectedLevelID: String!
    var selectedLevelIDSolution: String { selectedLevelID + " Solution" }
    var gameID: String!
    var gameProgress: GameProgress {
        let result = GameProgress.query().where(withFormat: "gameID = %@", withParameters: [gameID!]).fetch()
        if result.count == 0 {
            let rec = GameProgress()
            rec.gameID = gameID
            rec.levelID = levels[0].id
            return rec
        } else {
            return result[0] as! GameProgress
        }
    }
    private func getLevelProgress(levelID: String) -> LevelProgress {
        let result = LevelProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [gameID!, levelID]).fetch()
        if result.count == 0 {
            let rec = LevelProgress()
            rec.gameID = gameID
            rec.levelID = levelID
            return rec
        } else {
            return result[0] as! LevelProgress
        }
    }
    var levelProgress: LevelProgress { getLevelProgress(levelID: selectedLevelID) }
    var levelProgressSolution: LevelProgress { getLevelProgress(levelID: selectedLevelIDSolution) }
    private func getMoveProgress(levelID: String) -> SRKResultSet {
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [gameID!, levelID]).order("moveIndex").fetch()
    }
    var moveProgress: SRKResultSet { getMoveProgress(levelID: selectedLevelID) }
    var moveProgressSolution: SRKResultSet { getMoveProgress(levelID: selectedLevelIDSolution) }
    
    init() {
        // http://stackoverflow.com/questions/24494784/get-class-name-of-object-as-string-in-swift
        let gmTypeName = String(describing: type(of: GM.self))
        gameID = gmTypeName[0..<gmTypeName.length - "GameMove.Type".length]
        let path = Bundle.main.path(forResource: gameID, ofType: "xml")!
        let xml = try! String(contentsOfFile: path)
        let doc = try! XMLDocument(string: xml)
        let root = doc.root!
        for elemLevel in root.firstChild(tag: "levels")!.children {
            guard let key = elemLevel.attr("id") else {continue}
            let arr = elemLevel.stringValue.components(separatedBy: "\n")
                .filter { !$0.isBlank }.map { $0[0..<$0.length - 1] }
            levels.append(GameLevel(id: key, layout: arr, settings: elemLevel.attributes))
        }
        if let elemHelp = root.firstChild(tag: "help") {
            var arr = elemHelp.stringValue.components(separatedBy: "\n")
            arr = Array(arr[2..<(arr.count - 2)])
            help = arr
        }
        selectedLevelID = gameProgress.levelID
    }
    
    func levelUpdated(game: AnyObject) {
        let game = game as! GameBase
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func gameSolved(game: AnyObject) {
        let recLP = levelProgress
        let recLPS = levelProgressSolution
        guard recLPS.moveIndex == 0 || recLPS.moveIndex > recLP.moveIndex else {return}
        saveSolution(game: game)
    }

    func moveAdded(game: AnyObject, move: GM) {
        let game = game as! GameBase
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@ AND moveIndex >= %@", withParameters: [gameID!, selectedLevelID!, game.moveIndex]).fetch().remove()
        let rec = MoveProgress()
        rec.gameID = gameID
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        saveMove(move, to: rec)
        rec.commit()
    }
    
    func saveMove(_ move: GM, to rec: MoveProgress) {}
    
    func loadMove(from rec: MoveProgress) -> GM! { nil }
    
    func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    func clearGame() {
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [gameID!, selectedLevelID!]).fetch().remove()
        
        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
    
    private func copyMoves(moveProgressFrom: SRKResultSet, levelIDTo: String) {
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [gameID!, levelIDTo]).fetch().remove()
        for case let recMP as MoveProgress in moveProgressFrom {
            let move = loadMove(from: recMP)!
            let recMPS = MoveProgress()
            recMPS.gameID = gameID
            recMPS.levelID = levelIDTo
            recMPS.moveIndex = recMP.moveIndex
            saveMove(move, to: recMPS)
            recMPS.commit()
        }
    }
    
    func saveSolution(game: AnyObject) {
        copyMoves(moveProgressFrom: moveProgress, levelIDTo: selectedLevelIDSolution)
        let game = game as! GameBase
        let rec = levelProgressSolution
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func loadSolution() {
        let mps = moveProgressSolution
        copyMoves(moveProgressFrom: mps, levelIDTo: selectedLevelID)
        let rec = levelProgress
        rec.moveIndex = mps.count
        rec.commit()
    }
    
    func deleteSolution() {
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [gameID!, selectedLevelIDSolution]).fetch().remove()
        let rec = levelProgressSolution
        rec.moveIndex = 0
        rec.commit()
    }
    
    func resetAllLevels() {
        MoveProgress.query().where(withFormat: "gameID = %@", withParameters: [gameID!]).fetch().remove()
        LevelProgress.query().where(withFormat: "gameID = %@", withParameters: [gameID!]).fetch().remove()
    }
}
