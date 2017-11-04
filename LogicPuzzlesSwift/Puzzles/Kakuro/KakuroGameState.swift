//
//  KakuroGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class KakuroGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: KakuroGame {
        get {return getGame() as! KakuroGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: KakuroDocument { return KakuroDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return KakuroDocument.sharedInstance }
    var pos2num = [Position: Int]()
    var pos2horzState = [Position: HintState]()
    var pos2vertState = [Position: HintState]()

    override func copy() -> KakuroGameState {
        let v = KakuroGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: KakuroGameState) -> KakuroGameState {
        _ = super.setup(v: v)
        v.pos2num = pos2num
        v.pos2horzState = pos2horzState
        v.pos2vertState = pos2vertState
        return v
    }
    
    required init(game: KakuroGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        pos2num = game.pos2num
        updateIsSolved()
    }

    func setObject(move: inout KakuroGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && pos2num[p] != nil && pos2num[p] != move.obj else {return false}
        pos2num[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout KakuroGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && pos2num[p] != nil else {return false}
        let o = pos2num[p]!
        move.obj = (o + 1) % 10
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 4/Kakuro

        Summary
        Fill the board with numbers 1 to 9 according to the sums

        Description
        1. Your goal is to write a number in every blank tile (without a diagonal
           line).
        2. The number on the top of a column or at the left of a row, gives you
           the sum of the numbers in that column or row.
        3. You can write numbers 1 to 9 in the tiles, however no same number should
           appear in a consecutive row or column.
        4. Tiles which only have a diagonal line aren't used in the game.
    */
    private func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2horzHint {
            let os = KakuroGame.offset[1]
            var p2 = p + os
            var n1 = 0
            while let n = pos2num[p2] {
                n1 += n
                p2 += os
            }
            let s: HintState = n1 == 0 ? .normal : n1 == n2 ? .complete : .error
            pos2horzState[p] = s
            if s != .complete {isSolved = false}
        }
        for (p, n2) in game.pos2vertHint {
            let os = KakuroGame.offset[2]
            var p2 = p + os
            var n1 = 0
            while let n = pos2num[p2] {
                n1 += n
                p2 += os
            }
            let s: HintState = n1 == 0 ? .normal : n1 == n2 ? .complete : .error
            pos2vertState[p] = s
            if s != .complete {isSolved = false}
        }
    }
}
