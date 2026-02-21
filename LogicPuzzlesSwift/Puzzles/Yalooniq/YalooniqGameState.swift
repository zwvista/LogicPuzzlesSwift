//
//  YalooniqGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class YalooniqGameState: GridGameState<YalooniqGameMove> {
    var game: YalooniqGame {
        get { getGame() as! YalooniqGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { YalooniqDocument.sharedInstance }
    var objArray = [YalooniqObject]()
    var squares = Set<Position>()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    
    override func copy() -> YalooniqGameState {
        let v = YalooniqGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: YalooniqGameState) -> YalooniqGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.squares = squares
        return v
    }
    
    required init(game: YalooniqGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<YalooniqObject>(repeating: YalooniqObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> YalooniqObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> YalooniqObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout YalooniqGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        guard isValid(p: p) else { return .invalid }
        if dir == YalooniqGame.PUZ_DIR_SQUARE {
            guard self[p].testAll(is: false) else { return .invalid }
            if squares.remove(p) == nil { squares.insert(p) }
        } else {
            let p2 = p + YalooniqGame.offset[dir], dir2 = (dir + 2) % 4
            guard isValid(p: p2) && game.pos2hint[p] == nil && !squares.contains(p) && !squares.contains(p2) else { return .invalid }
            self[p][dir].toggle()
            self[p2][dir2].toggle()
        }
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 6/Yalooniq

        Summary
        Loops, Arrows and Squares

        Description
        1. The goal is to draw a single Loop on the board, similarly to LineSweeper.
        2. The Loop must go through ALL the available tiles on the board.
        3. The available tiles on which the Loop must go are the ones without
           Arrows and also not containing Squares.
        4. It is up to you to find the Squares, which are pointed at by the Arrows!
        5. The numbers beside the Arrows tell you how many Squares are present
           in that direction, from that point.
        6. The Squares can't touch horizontally or vertically.
        7. Lastly, please keep in mind that if there aren't Arrows pointing to
           a tile, that tile can contain a Square too!
    */
    private func updateIsSolved() {
        isSolved = true
        // 4. It is up to you to find the Squares, which are pointed at by the Arrows!
        // 5. The numbers beside the Arrows tell you how many Squares are present
        //    in that direction, from that point.
        for (p, hint) in game.pos2hint {
            let n2 = hint.num
            let os = YalooniqGame.offset[hint.dir]
            var n1 = 0
            var p2 = p + os
            while isValid(p: p2) {
                if squares.contains(p2) { n1 += 1 }
                p2 += os
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2stateHint[p] = s
            if s != .complete { isSolved = false }
        }
        // 6. The Squares can't touch horizontally or vertically.
        for p in squares {
            let s: AllowedObjectState = (!YalooniqGame.offset.contains {
                squares.contains(p + $0)
            }) ? .normal : .error
            pos2stateAllowed[p] = s
            if s == .error { isSolved = false }
        }
        guard isSolved else {return}
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    // 1. Draw a loop that runs through all tiles.
                    pos2dirs[p] = dirs
                } else if !(dirs.isEmpty && (game.pos2hint[p] != nil || squares.contains(p))) {
                    // 2. The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        let p = pos2dirs.keys.first!
        var p2 = p, n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += YalooniqGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
