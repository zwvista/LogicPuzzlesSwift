//
//  OnlyBendsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class OnlyBendsGameState: GridGameState<OnlyBendsGameMove> {
    var game: OnlyBendsGame {
        get { getGame() as! OnlyBendsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { OnlyBendsDocument.sharedInstance }
    var objArray = [OnlyBendsObject]()
    
    override func copy() -> OnlyBendsGameState {
        let v = OnlyBendsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: OnlyBendsGameState) -> OnlyBendsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: OnlyBendsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<OnlyBendsObject>(repeating: OnlyBendsObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> OnlyBendsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> OnlyBendsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout OnlyBendsGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + OnlyBendsGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 1/Only Bends

        Summary
        We don't like long straights

        Description
        1. Connect pairs of houses with roads that can't go straight! :)
        2. Each house must be connected with another house. The road connecting
           them can't have straights, but has to turn on every tile it passes through.
        3. Roads cannot cross and cannot go over other houses.
        4. The entire board must be filled with roads! (asphalt lobby rule)
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
            p2 += OnlyBendsGame.offset[n]
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
