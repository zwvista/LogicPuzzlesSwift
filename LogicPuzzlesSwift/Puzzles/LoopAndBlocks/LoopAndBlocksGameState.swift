//
//  LoopAndBlocksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LoopAndBlocksGameState: GridGameState<LoopAndBlocksGameMove> {
    var game: LoopAndBlocksGame {
        get { getGame() as! LoopAndBlocksGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LoopAndBlocksDocument.sharedInstance }
    var objArray = [LoopAndBlocksObject]()
    
    override func copy() -> LoopAndBlocksGameState {
        let v = LoopAndBlocksGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LoopAndBlocksGameState) -> LoopAndBlocksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LoopAndBlocksGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LoopAndBlocksObject>(repeating: LoopAndBlocksObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> LoopAndBlocksObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LoopAndBlocksObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout LoopAndBlocksGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + LoopAndBlocksGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/Loop and Blocks

        Summary
        Don't block me now

        Description
        1. Draw a loop that passes through each clear tile.
        2. The loop must be a single one and can't intersect itself.
        3. A number in a cell shows how many cell must be shaded around its
           four sides.
        4. Not all cells that must be shaded are given with a hint. Two shaded
           cells can't touch orthogonally.
        5. The loop must pass over every cell that hasn't got a number or has
           not been shaded.
    */
    private func updateIsSolved() {
        isSolved = true
        var chOneArray = [Position]()
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let ch = game[p]
                let dirs = (0..<4).filter { o[$0] }
                switch dirs.count {
                case 1:
                    // 2. You should draw as many lines into the grid as number sets:
                    //    a line starts with the number 1, goes through the numbers in
                    //    order up to the highest, where it ends.
                    guard ch == LoopAndBlocksGame.PUZ_ONE || ch == game.chMax else { isSolved = false; return }
                    if ch == LoopAndBlocksGame.PUZ_ONE { chOneArray.append(p) }
                    pos2dirs[p] = dirs
                case 2:
                    pos2dirs[p] = dirs
                default:
                    // 3. In doing this, you have to pass through all tiles on the board.
                    //    Lines cannot cross.
                    isSolved = false; return
                }
            }
        }
        // 2. You should draw as many lines into the grid as number sets:
        //    a line starts with the number 1, goes through the numbers in
        //    order up to the highest, where it ends.
        for p in chOneArray {
            var chars = String(LoopAndBlocksGame.PUZ_ONE)
            var i = pos2dirs[p]!.first!
            var os = LoopAndBlocksGame.offset[i]
            var p2 = p + os
            while true {
                let ch = game[p2]
                if ch != " " { chars.append(ch) }
                let j = (i + 2) % 4
                var dirs = pos2dirs[p2]!
                if !dirs.contains(j) { isSolved = false; return }
                dirs = dirs.filter { $0 != j }
                guard !dirs.isEmpty else {break}
                i = dirs.first!
                os = LoopAndBlocksGame.offset[i]
                p2 += os
            }
            if chars != game.expectedChars { isSolved = false; return }
        }
    }
}
