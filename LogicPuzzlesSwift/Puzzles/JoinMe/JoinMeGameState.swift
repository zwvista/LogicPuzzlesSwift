//
//  JoinMeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import OrderedCollections

class JoinMeGameState: GridGameState<JoinMeGameMove> {
    var game: JoinMeGame {
        get { getGame() as! JoinMeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { JoinMeDocument.sharedInstance }
    var objArray = [JoinMeObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()

    override func copy() -> JoinMeGameState {
        let v = JoinMeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: JoinMeGameState) -> JoinMeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: JoinMeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<JoinMeObject>(repeating: JoinMeObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> JoinMeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> JoinMeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout JoinMeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout JoinMeGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: JoinMeObject) -> JoinMeObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .water()
            case .water:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .water() : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 2/Join Me!

        Summary
        Communicating Vessels

        Description
        1. Connect the different patches with one stitch (more in later levels).
        2. The numbers on the outside tell you how many stitches you can see from
           there in the row/column.
        3. A cell can contain only one stitch.
        4. Later levels will show you in the top right how many stitches you have
           to put between patches.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] { self[r, c] = .empty }
            }
        }
        // 2. You have to fill some water in it, considering that water pours down
        //    and levels itself like in reality.
        // 3. Areas of the same level which are horizontally connected will have
        //    the same water level.
        for area in game.areas {
            let row2rng = OrderedDictionary(grouping: area) { $0.row }
            guard let rowNotFilled = row2rng.keys.reversed().first(where: {
                row2rng[$0]!.contains { self[$0].toString() != "water" }
            }) else {continue}
            let rng = area.filter { self[$0].toString() == "water" }
            let rngError = rng.filter { $0.row < rowNotFilled }
            rng.forEach { self[$0] = .water() }
            guard !rngError.isEmpty else {continue}
            isSolved = false
            rngError.forEach { self[$0] = .water(state: .error) }
        }
        // 4. The numbers on the border show you how many tiles of each row and
        //    column are filled.
        for r in 0..<rows {
            let n2 = game.row2hint[r]
            guard n2 != JoinMeGame.PUZ_UNKNOWN else {continue}
            let n1 = (0..<cols).count { self[r, $0].toString() == "water" }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
            guard s != .normal && allowedObjectsOnly else {continue}
            (0..<cols).filter { self[r, $0].toString() == "empty" }.forEach {
                self[r, $0] = .forbidden
            }
        }
        for c in 0..<cols {
            let n2 = game.col2hint[c]
            guard n2 != JoinMeGame.PUZ_UNKNOWN else {continue}
            let n1 = (0..<rows).count { self[$0, c].toString() == "water" }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
            guard s != .normal && allowedObjectsOnly else {continue}
            (0..<rows).filter { self[$0, c].toString() == "empty" }.forEach {
                self[$0, c] = .forbidden
            }
        }
    }
}
