//
//  GameDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import RealmSwift
import Fuzi

struct GameLevel {
    var id: String
    var layout: [String]
    var settings: [String: String]
}

protocol GameDocumentBase: AnyObject {
    var gameProgress: GameProgress { get }
    var levelProgress: LevelProgress { get }
    var moveProgress: Results<MoveProgress> { get }
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
    let realm = try! Realm()
    var selectedLevelID: String!
    var selectedLevelIDSolution: String { selectedLevelID + " Solution" }
    var gameID: String!
    var gameProgress: GameProgress {
        let result = realm.objects(GameProgress.self).filter(NSPredicate(format: "gameID = %@", gameID!))
        if result.count == 0 {
            let rec = GameProgress()
            rec.gameID = gameID
            rec.levelID = levels[0].id
            return rec
        } else {
            return result[0]
        }
    }
    private func getLevelProgress(levelID: String) -> LevelProgress {
        let result = realm.objects(LevelProgress.self).filter(NSPredicate(format: "gameID = %@ AND levelID = %@", gameID!, levelID))
        if result.count == 0 {
            let rec = LevelProgress()
            rec.gameID = gameID
            rec.levelID = levelID
            return rec
        } else {
            return result[0]
        }
    }
    var levelProgress: LevelProgress { getLevelProgress(levelID: selectedLevelID) }
    var levelProgressSolution: LevelProgress { getLevelProgress(levelID: selectedLevelIDSolution) }
    private func getMoveProgress(levelID: String) -> Results<MoveProgress> {
        realm.objects(MoveProgress.self).filter(NSPredicate(format: "gameID = %@ AND levelID = %@", gameID!, levelID)).sorted(byKeyPath: "moveIndex")
    }
    var moveProgress: Results<MoveProgress> { getMoveProgress(levelID: selectedLevelID) }
    var moveProgressSolution: Results<MoveProgress> { getMoveProgress(levelID: selectedLevelIDSolution) }
    
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
        try! realm.write {
            let rec = levelProgress
            rec.moveIndex = game.moveIndex
            realm.add(rec, update: .all)
        }
    }
    
    func gameSolved(game: AnyObject) {
        let recLP = levelProgress
        let recLPS = levelProgressSolution
        guard recLPS.moveIndex == 0 || recLPS.moveIndex > recLP.moveIndex else {return}
        saveSolution(game: game)
    }

    func moveAdded(game: AnyObject, move: GM) {
        let game = game as! GameBase
        try! realm.write {
            // https://stackoverflow.com/questions/28620794/swift-nspredicate-throwing-exc-bad-accesscode-1-address-0x1-when-compounding
            realm.delete(realm.objects(MoveProgress.self).filter(NSPredicate(format: "gameID = %@ AND levelID = %@ AND moveIndex >= %ld", gameID!, selectedLevelID!, game.moveIndex)))
            let rec = MoveProgress()
            rec.gameID = gameID
            rec.levelID = selectedLevelID
            rec.moveIndex = game.moveIndex
            saveMove(move, to: rec)
            realm.add(rec, update: .all)
        }
    }
    
    func saveMove(_ move: GM, to rec: MoveProgress) {}
    
    func loadMove(from rec: MoveProgress) -> GM! { nil }
    
    func resumeGame() {
        try! realm.write {
            let rec = gameProgress
            rec.levelID = selectedLevelID
            realm.add(rec, update: .all)
        }
    }
    
    func clearGame() {
        try! realm.write {
            realm.delete(realm.objects(MoveProgress.self).filter(NSPredicate(format: "gameID = %@ AND levelID = %@", gameID!, selectedLevelID!)))
            let rec = levelProgress
            rec.moveIndex = 0
            realm.add(rec, update: .all)
        }
    }
    
    private func copyMoves(moveProgressFrom: Results<MoveProgress>, levelIDTo: String) {
        try! realm.write {
            realm.delete(realm.objects(MoveProgress.self).filter(NSPredicate(format: "gameID = %@ AND levelID = %@", gameID!, levelIDTo)))
            for recMP in moveProgressFrom {
                let move = loadMove(from: recMP)!
                let recMPS = MoveProgress()
                recMPS.gameID = gameID
                recMPS.levelID = levelIDTo
                recMPS.moveIndex = recMP.moveIndex
                saveMove(move, to: recMPS)
                realm.add(recMPS, update: .all)
            }
        }
    }
    
    func saveSolution(game: AnyObject) {
        copyMoves(moveProgressFrom: moveProgress, levelIDTo: selectedLevelIDSolution)
        let game = game as! GameBase
        try! realm.write {
            let rec = levelProgressSolution
            rec.moveIndex = game.moveIndex
            realm.add(rec, update: .all)
        }
    }
    
    func loadSolution() {
        let mps = moveProgressSolution
        copyMoves(moveProgressFrom: mps, levelIDTo: selectedLevelID)
        try! realm.write {
            let rec = levelProgress
            rec.moveIndex = mps.count
            realm.add(rec, update: .all)
        }
    }
    
    func deleteSolution() {
        try! realm.write {
            realm.delete(realm.objects(MoveProgress.self).filter(NSPredicate(format: "gameID = %@ AND levelID = %@", gameID!, selectedLevelIDSolution)))
            let rec = levelProgressSolution
            rec.moveIndex = 0
            realm.add(rec, update: .all)
        }
    }
    
    func resetAllLevels() {
        try! realm.write {
            realm.delete(realm.objects(MoveProgress.self).filter(NSPredicate(format: "gameID = %@", gameID!)))
            realm.delete(realm.objects(LevelProgress.self).filter(NSPredicate(format: "gameID = %@", gameID!)))
        }
    }
}
