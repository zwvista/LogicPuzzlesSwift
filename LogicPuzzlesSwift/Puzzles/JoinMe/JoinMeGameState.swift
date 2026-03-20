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
        objArray = Array<JoinMeObject>(repeating: JoinMeObject(repeating: false, count: 4), count: rows * cols)
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
        let p = move.p, dir = move.dir
        let p2 = p + JoinMeGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
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
        isSolved = true
        var area2patchArray = game.area2areas.map { areas in
            var area2patch = [Int: Int]()
            for a in areas {
                area2patch[a] = 0
            }
            return area2patch
        }
        var row2patch = Array(repeating: 0, count: rows)
        var col2patch = Array(repeating: 0, count: cols)
        for r in 0..<rows {
            for c in 0..<cols {
                let p1 = Position(r, c)
                let a1 = game.pos2area[p1]!
                for i in 0..<4 {
                    guard self[p1][i] else {continue}
                    let p2 = p1 + JoinMeGame.offset[i]
                    let a2 = game.pos2area[p2]!
                    if a1 == a2 {
                        isSolved = false
                    } else {
                        area2patchArray[a1][a2] = area2patchArray[a1][a2]! + 1
                    }
                    guard i == 1 || i == 2 else {continue}
                    row2patch[p1.row] += 1
                    col2patch[p1.col] += 1
                    row2patch[p2.row] += 1
                    col2patch[p2.col] += 1
                }
            }
        }
        if !(area2patchArray.allSatisfy {
            $0.allSatisfy { $1 == game.stitches }
        }) { isSolved = false }
        for r in 0..<rows {
            let n1 = row2patch[r], n2 = game.row2hint[r]
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == JoinMeGame.PUZ_UNKNOWN ? .complete : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
        }
        for c in 0..<cols {
            let n1 = col2patch[c], n2 = game.col2hint[c]
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == JoinMeGame.PUZ_UNKNOWN ? .complete : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
        }
    }
}
