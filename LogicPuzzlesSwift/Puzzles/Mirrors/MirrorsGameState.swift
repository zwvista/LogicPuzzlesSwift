//
//  MirrorsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MirrorsGameState: GridGameState<MirrorsGameMove> {
    var game: MirrorsGame {
        get { getGame() as! MirrorsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MirrorsDocument.sharedInstance }
    var objArray = [MirrorsObject]()
    
    override func copy() -> MirrorsGameState {
        let v = MirrorsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MirrorsGameState) -> MirrorsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MirrorsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MirrorsObject>(repeating: MirrorsObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MirrorsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MirrorsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MirrorsGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + MirrorsGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && game[p] != MirrorsGame.PUZ_BLOCK && game[p2] != MirrorsGame.PUZ_BLOCK else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 10/Mirrors

        Summary
        Zip, swish, zoom! Lasers on mirrors!

        Description
        1. The goal is to draw a single, continuous, non-crossing path that fills
           the entire board.
        2. Some tiles are already given and can contain Mirrors, which force the
           path to make a turn. Other tiles already contain a fixed piece of straight
           path.
        3. Your task is to fill the remaining board tiles with straight or 90 degree
           path lines, in the end connecting a single, continuous line.
        4. Please note you can make 90 degree turn even there are no mirrors.

        Variant
        5. In the Maze variant, the path isn't closed. You have two spots on the
           board which represent the start and end of the path.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    // 1. Draw a loop that runs through all tiles.
                    pos2dirs[p] = dirs
                } else if !(dirs.isEmpty && game[p] == MirrorsGame.PUZ_BLOCK) {
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
            p2 += MirrorsGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
