//
//  StraightAndTurnGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class StraightAndTurnGameState: GridGameState<StraightAndTurnGameMove> {
    var game: StraightAndTurnGame {
        get { getGame() as! StraightAndTurnGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { StraightAndTurnDocument.sharedInstance }
    var objArray = [StraightAndTurnObject]()
    
    override func copy() -> StraightAndTurnGameState {
        let v = StraightAndTurnGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: StraightAndTurnGameState) -> StraightAndTurnGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: StraightAndTurnGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<StraightAndTurnObject>(repeating: StraightAndTurnObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> StraightAndTurnObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> StraightAndTurnObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout StraightAndTurnGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + StraightAndTurnGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/Straight and Turn

        Summary
        Straight and Turn

        Description
        1. Draw a path that crosses all gems and follows this rule:
        2. Crossing two adjacent gems:
        3. The line cannot cross two adjacent gems if they are of different color.
        4. The line is free to either go straight or turn when crossing two
           adjacent gems of the same color.
        5. Crossing a gem that is not adjacent to the last crossed:
        6. The line should go straight in the space between two gems of the same
           colour.
        7. The line should make a single 90 degree turn in the space between
           two gems of different colour.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    // 1. Draw a path that crosses all gems
                    pos2dirs[p] = dirs
                } else if !(dirs.isEmpty && game[p] == " ") {
                    // The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        guard let p = pos2dirs.keys.first(where: { game[$0] != " " }) else { isSolved = false; return }
        var p2 = p
        var n = -1, ns = [Int]()
        var ch = game[p]
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            ns.append(n)
            p2 += StraightAndTurnGame.offset[n]
            let ch2 = game[p2]
            if ch2 != " " {
                // 2. Crossing two adjacent gems:
                // 3. The line cannot cross two adjacent gems if they are of different color.
                // 4. The line is free to either go straight or turn when crossing two
                //    adjacent gems of the same color.
                // 5. Crossing a gem that is not adjacent to the last crossed:
                // 6. The line should go straight in the space between two gems of the same
                //    colour.
                // 7. The line should make a single 90 degree turn in the space between
                //    two gems of different colour.
                let turns = (0..<ns.count - 1).count { ns[$0] != ns[$0 + 1] }
                guard ch == ch2 && turns == 0 || ch != ch2 && turns == 1 else { isSolved = false; return }
                ch = ch2
                ns.removeAll()
            }
            guard p2 != p else {break}
        }
    }
}
