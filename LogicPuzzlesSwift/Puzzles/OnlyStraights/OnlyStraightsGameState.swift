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
        var pos2Dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    pos2Dirs[p] = dirs
                    if game[p] != " " {
                        // 2. The path should make 90 degrees turns on the spots.
                        guard dirs[1] - dirs[0] != 2 else { isSolved = false; return }
                    }
                } else {
                    // 1. Fill the board with a loop that passes through all tiles.
                    // The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        guard let p = pos2Dirs.keys.first(where: { game[$0] != " " }) else { isSolved = false; return }
        var p2 = p
        var n = -1, ns = [Int]()
        while true {
            guard let dirs = pos2Dirs[p2] else { isSolved = false; return }
            pos2Dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            ns.append(n)
            p2 += OnlyStraightsGame.offset[n]
            if game[p2] != " " {
                // 3. Between spots, the path makes one more 90 degrees turn.
                let turns = (0..<ns.count - 1).count { ns[$0] != ns[$0 + 1] }
                guard turns == 1 else { isSolved = false; return }
                ns.removeAll()
            }
            guard p2 != p else {return}
        }
    }
}
