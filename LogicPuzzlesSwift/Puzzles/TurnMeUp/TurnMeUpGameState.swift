//
//  TurnMeUpGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TurnMeUpGameState: GridGameState<TurnMeUpGameMove> {
    var game: TurnMeUpGame {
        get { getGame() as! TurnMeUpGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TurnMeUpDocument.sharedInstance }
    var objArray = [TurnMeUpObject]()
    
    override func copy() -> TurnMeUpGameState {
        let v = TurnMeUpGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TurnMeUpGameState) -> TurnMeUpGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TurnMeUpGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TurnMeUpObject>(repeating: TurnMeUpObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> TurnMeUpObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TurnMeUpObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TurnMeUpGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + TurnMeUpGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Turn me up

        Summary
        How many turns

        Description
        1. Connect the circles between them, in pairs.
        2. The number on the circle tells you how many turns the connection
           does between circles.
        3. Two circles without numbers can have any number of turns.
        4. All tiles on the board must be used and all circles must be connected.
    */
    private func updateIsSolved() {
        isSolved = true
        var chOneArray = [Position]()
        var ch2dirs = [Position: [Int]]()
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
                    guard ch == TurnMeUpGame.PUZ_ONE || ch == game.chMax else { isSolved = false; return }
                    if ch == TurnMeUpGame.PUZ_ONE { chOneArray.append(p) }
                    ch2dirs[p] = dirs
                case 2:
                    ch2dirs[p] = dirs
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
            var chars = String(TurnMeUpGame.PUZ_ONE)
            var i = ch2dirs[p]!.first!
            var os = TurnMeUpGame.offset[i]
            var p2 = p + os
            while true {
                let ch = game[p2]
                if ch != " " { chars.append(ch) }
                let j = (i + 2) % 4
                var dirs = ch2dirs[p2]!
                if !dirs.contains(j) { isSolved = false; return }
                dirs = dirs.filter { $0 != j }
                guard !dirs.isEmpty else {break}
                i = dirs.first!
                os = TurnMeUpGame.offset[i]
                p2 += os
            }
            if chars != game.expectedChars { isSolved = false; return }
        }
    }
}
