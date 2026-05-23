//
//  SukrokuroGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SukrokuroGameState: GridGameState<SukrokuroGameMove> {
    var game: SukrokuroGame {
        get { getGame() as! SukrokuroGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SukrokuroDocument.sharedInstance }
    var pos2num = [Position: Int]()
    var pos2horzState = [Position: HintState]()
    var pos2vertState = [Position: HintState]()
    var dotsVertState = [Position: HintState]()
    var dotsHorzState = [Position: HintState]()

    override func copy() -> SukrokuroGameState {
        let v = SukrokuroGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SukrokuroGameState) -> SukrokuroGameState {
        _ = super.setup(v: v)
        v.pos2num = pos2num
        v.pos2horzState = pos2horzState
        v.pos2vertState = pos2vertState
        return v
    }
    
    required init(game: SukrokuroGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        pos2num = game.pos2num
        updateIsSolved()
    }

    override func setObject(move: inout SukrokuroGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && pos2num[p] != nil && pos2num[p] != move.obj else { return .invalid }
        pos2num[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout SukrokuroGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && pos2num[p] != nil else { return .invalid }
        let o = pos2num[p]!
        move.obj = (o + 1) % 10
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 4/Sukrokuro

        Summary
        All mixed up!

        Description
        1. Sukrokuro combines Sudoku, Kropki and Kakuro.
        2. Fill in the white cells, one number in each, so that each column and row
           contains the nubmers 1 through 7 exactly once.
        3. Black cells contain clues, which tell you the sum of the number in
           consecutive cells at its right and downward.
        4. A dot separated tiles where the absolute difference between the numbers
           is 1.
        5. If a dot is absent between two cells, the difference between the numbers
           must be more than 1.
    */
    private func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2horzHint {
            let os = SukrokuroGame.offset[1]
            var p2 = p + os
            var n1 = 0, lastN = 0
            while let n = pos2num[p2] {
                n1 += n
                p2 += os
                // 3. You can write numbers 1 to 9 in the tiles, however no same number should
                // appear in a consecutive row.
                if n == lastN {
                    isSolved = false
                    pos2horzState[p2] = .error
                    pos2horzState[p2 - os] = .error
                }
                lastN = n
            }
            // 2. The number on at the left of a row gives you
            // the sum of the numbers in that row.
            let s: HintState = n1 == 0 ? .normal : n1 == n2 ? .complete : .error
            pos2horzState[p] = s
            if s != .complete { isSolved = false }
        }
        for (p, n2) in game.pos2vertHint {
            let os = SukrokuroGame.offset[2]
            var p2 = p + os
            var n1 = 0, lastN = 0
            while let n = pos2num[p2] {
                n1 += n
                p2 += os
                // 3. You can write numbers 1 to 9 in the tiles, however no same number should
                // appear in a consecutive column.
                if n == lastN {
                    isSolved = false
                    pos2vertState[p2] = .error
                    pos2vertState[p2 - os] = .error
                }
                lastN = n
            }
            // 2. The number on the top of a column gives you
            // the sum of the numbers in that column.
            let s: HintState = n1 == 0 ? .normal : n1 == n2 ? .complete : .error
            pos2vertState[p] = s
            if s != .complete { isSolved = false }
        }
        for p in game.dotsVert {
            let (n1, n2) = (pos2num[p]!, pos2num[p + Position.South]!)
            let s: HintState = n1 == 0 || n2 == 0 ? .normal : abs(n1 - n2) == 1 ? .complete : .error
            dotsVertState[p] = s
            if s != .complete { isSolved = false }
        }
        for p in game.dotsHorz {
            let (n1, n2) = (pos2num[p]!, pos2num[p + Position.East]!)
            let s: HintState = n1 == 0 || n2 == 0 ? .normal : abs(n1 - n2) == 1 ? .complete : .error
            dotsHorzState[p] = s
            if s != .complete { isSolved = false }
        }
    }
}
