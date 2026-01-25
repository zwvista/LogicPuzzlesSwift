//
//  YouTurnMeOnGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class YouTurnMeOnGameState: GridGameState<YouTurnMeOnGameMove> {
    var game: YouTurnMeOnGame {
        get { getGame() as! YouTurnMeOnGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { YouTurnMeOnDocument.sharedInstance }
    var objArray = [YouTurnMeOnObject]()
    var pos2state = [Position: HintState]()

    override func copy() -> YouTurnMeOnGameState {
        let v = YouTurnMeOnGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: YouTurnMeOnGameState) -> YouTurnMeOnGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: YouTurnMeOnGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<YouTurnMeOnObject>(repeating: YouTurnMeOnObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> YouTurnMeOnObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> YouTurnMeOnObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout YouTurnMeOnGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + YouTurnMeOnGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 3/You Turn me on

        Summary
        Sometimes you do, sometimes you don't

        Description
        1. Draw a single, no intersecting loop.
        2. The number on each region tells you how many turns the path does
           in that region.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                pos2dirs[p] = dirs
                if dirs.count != 2 {
                    // 1. Draw a single, no intersecting loop.
                    isSolved = false
                }
            }
        }
        // 2. The number on each region tells you how many turns the path does
        //    in that region.
        for (p, n2) in game.pos2hint {
            let area = game.areas[game.pos2area[p]!]
            let n1 = area.reduce(0) { acc, p in
                let dirs = pos2dirs[p]!
                return acc + (dirs.count == 2 && dirs[1] - dirs[0] != 2 ? 1 : 0)
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s != .complete { isSolved = false }
            pos2state[p] = s
        }
        guard isSolved else {return}
        // Check the loop
        guard let p = pos2dirs.keys.first else { isSolved = false; return }
        var p2 = p, n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += YouTurnMeOnGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
