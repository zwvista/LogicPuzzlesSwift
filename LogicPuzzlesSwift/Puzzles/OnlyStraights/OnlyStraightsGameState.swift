//
//  OnlyStraightsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class OnlyStraightsGameState: GridGameState<OnlyStraightsGameMove> {
    var game: OnlyStraightsGame {
        get { getGame() as! OnlyStraightsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { OnlyStraightsDocument.sharedInstance }
    var objArray = [OnlyStraightsObject]()
    
    override func copy() -> OnlyStraightsGameState {
        let v = OnlyStraightsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: OnlyStraightsGameState) -> OnlyStraightsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: OnlyStraightsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<OnlyStraightsObject>(repeating: OnlyStraightsObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> OnlyStraightsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> OnlyStraightsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout OnlyStraightsGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + OnlyStraightsGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 4/Only Straights

        Summary
        We loooove long straights

        Description
        1. Draw a non-intersecting loop that visits all towns.
        2. This time, you must go straight while passing a town.
        3. Branches of a road coming off a town must be of equal length.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    pos2dirs[p] = dirs
                    if game[p] != " " {
                        // 2. This time, you must go straight while passing a town.
                        guard dirs[1] - dirs[0] == 2 else { isSolved = false; return }
                    }
                } else if !dirs.isEmpty {
                    // The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        let pos2dirs2 = pos2dirs
        // Check the loop
        guard let p = pos2dirs.keys.first else { isSolved = false; return }
        var p2 = p
        var n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += OnlyStraightsGame.offset[n]
            guard p2 != p else {break}
        }
        // 3. Branches of a road coming off a town must be of equal length.
        if !pos2dirs2.allSatisfy({ (p, dirs) in
            func f(d: Int) -> Int {
                let os = OnlyStraightsGame.offset[d]
                var p2 = p + os
                var n = 0
                while pos2dirs2[p2]!.contains(d) {
                    n += 1
                    p2 += os
                }
                return n
            }
            return game[p] == " " || f(d: dirs[0]) == f(d: dirs[1])
        }) { isSolved = false }
    }
}
