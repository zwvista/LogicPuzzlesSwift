//
//  TrafficWardenGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TrafficWardenGameState: GridGameState<TrafficWardenGameMove> {
    var game: TrafficWardenGame {
        get { getGame() as! TrafficWardenGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TrafficWardenDocument.sharedInstance }
    var objArray = [TrafficWardenObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> TrafficWardenGameState {
        let v = TrafficWardenGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TrafficWardenGameState) -> TrafficWardenGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TrafficWardenGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TrafficWardenObject>(repeating: TrafficWardenObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> TrafficWardenObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TrafficWardenObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TrafficWardenGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + TrafficWardenGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 2/Traffic Warden

        Summary
        But the light was green!

        Description
        1. Draw a single non intersecting, continuous looping path which must
           follow these rules at every traffic light:
        2. While passing on green lights, the road must go straight, it can't turn.
        3. While passing on red lights, the road must turn 90 degrees.
        4. While passing on yellow lights, the road might turn 90 degrees or
           go straight.
        5. A number on the light tells you the length of the straights coming
           out of that tile.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                pos2dirs[p] = dirs
                // 1. Draw a single non intersecting, continuous looping path
                if !(dirs.count == 2 || dirs.isEmpty && game.pos2hint[p] == nil) { isSolved = false }
            }
        }
        for (p, hint) in game.pos2hint {
            let ch = hint.light
            let dirs = pos2dirs[p]!
            // 2. While passing on green lights, the road must go straight, it can't turn.
            // 3. While passing on red lights, the road must turn 90 degrees.
            // 4. While passing on yellow lights, the road might turn 90 degrees or
            //    go straight.
            if !(dirs.count == 2 && ((ch == TrafficWardenGame.PUZ_GREEN || ch == TrafficWardenGame.PUZ_YELLOW) && dirs[1] - dirs[0] == 2 || (ch == TrafficWardenGame.PUZ_RED || ch == TrafficWardenGame.PUZ_YELLOW) && dirs[1] - dirs[0] != 2)) {
                isSolved = false; pos2state[p] = .normal
            } else {
                // 5. A number on the light tells you the length of the straights coming
                //    out of that tile.
                let n2 = hint.len
                var n1 = 0
                for d in dirs {
                    let os = TrafficWardenGame.offset[d]
                    var p2 = p + os
                    n1 += 1
                    while true {
                        let dirs2 = pos2dirs[p2]!
                        if !dirs2.contains(d) {break}
                        p2 += os
                        n1 += 1
                    }
                }
                let s: HintState = n1 == n2 ? .complete : .error
                if s != .complete { isSolved = false }
                pos2state[p] = s
            }
        }
        guard isSolved else {return}
        // Check the loop
        guard let p = pos2dirs.keys.first else { isSolved = false; return }
        var p2 = p, n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += TrafficWardenGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
