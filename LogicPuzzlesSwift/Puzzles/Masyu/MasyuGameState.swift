//
//  MasyuGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MasyuGameState: GridGameState<MasyuGameMove> {
    var game: MasyuGame {
        get { getGame() as! MasyuGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MasyuDocument.sharedInstance }
    var objArray = [MasyuObject]()
    
    override func copy() -> MasyuGameState {
        let v = MasyuGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MasyuGameState) -> MasyuGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MasyuGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MasyuObject>(repeating: MasyuObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MasyuObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MasyuObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MasyuGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + MasyuGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: Logic Games/Puzzle Set 3/Masyu

        Summary
        Draw a Necklace that goes through every Pearl

        Description
        1. The goal is to draw a single Loop(Necklace) through every circle(Pearl)
           that never branches-off or crosses itself.
        2. The rules to pass Pearls are:
        3. Lines passing through White Pearls must go straight through them.
           However, at least at one side of the White Pearl(or both), they must
           do a 90 degree turn.
        4. Lines passing through Black Pearls must do a 90 degree turn in them.
           Then they must go straight in the next tile in both directions.
        5. Lines passing where there are no Pearls can do what they want.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = game[p]
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    pos2dirs[p] = dirs
                    if ch == MasyuGame.PUZ_BLACK_PEARL {
                        // 4. Lines passing through Black Pearls must do a 90 degree turn in them.
                        guard dirs[1] - dirs[0] != 2 else { isSolved = false; return }
                    } else if ch == MasyuGame.PUZ_WHITE_PEARL {
                        // 3. Lines passing through White Pearls must go straight through them.
                        guard dirs[1] - dirs[0] == 2 else { isSolved = false; return }
                    }
                } else if !(dirs.isEmpty && ch == " ") {
                    // 1. The goal is to draw a single Loop(Necklace) through every circle(Pearl)
                    //    that never branches-off or crosses itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        guard let p = pos2dirs.keys.first else { isSolved = false; return }
        var p2 = p
        var n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += MasyuGame.offset[n]
            guard p2 != p else {break}
        }
        // 3. At least at one side of the White Pearl(or both), they must do a 90 degree turn.
        // 4. Lines passing through Black Pearls must go straight in the next tile in both directions.
        // 5. Lines passing where there are no Pearls can do what they want.
        if !pos2dirs.testAll({ p, dirs in
            let ch = game[p]
            guard ch != " " else { return true }
            let turns = dirs.reduce(0) { acc, d in
                let dirs2 = pos2dirs[p + MasyuGame.offset[d]]!
                return acc + (dirs2[1] - dirs2[0] != 2 ? 1 : 0)
            }
            return ch == MasyuGame.PUZ_BLACK_PEARL && turns == 0 || ch == MasyuGame.PUZ_WHITE_PEARL && turns > 0
        }) { isSolved = false }
    }
}
