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
        var circles = Set<Position>()
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let ch = game[p]
                let dirs = (0..<4).filter { o[$0] }
                // 2. The number on the circle tells you how many turns the connection
                //    does between circles.
                switch dirs.count {
                case 1:
                    guard ch != " " else { isSolved = false; return }
                    circles.insert(p)
                    pos2dirs[p] = dirs
                case 2:
                    guard ch == " " else { isSolved = false; return }
                    pos2dirs[p] = dirs
                default:
                    // 4. All tiles on the board must be used
                    isSolved = false; return
                }
            }
        }
        // 2. You should draw as many lines into the grid as number sets:
        //    a line starts with the number 1, goes through the numbers in
        //    order up to the highest, where it ends.
        while !circles.isEmpty {
            let p = circles.first!
            let ch1 = game[p]
            var i = pos2dirs[p]!.first!
            var os = TurnMeUpGame.offset[i]
            var p2 = p + os
            var turns = 0
            while true {
                let j = (i + 2) % 4
                var dirs = pos2dirs[p2]!
                dirs = dirs.filter { $0 != j }
                guard !dirs.isEmpty else {break}
                let k = dirs.first!
                if k != i {
                    turns += 1
                    i = k
                }
                os = TurnMeUpGame.offset[i]
                p2 += os
            }
            let ch2 = game[p2]
            guard ch1 == TurnMeUpGame.PUZ_QM || ch2 == TurnMeUpGame.PUZ_QM || ch1 == ch2 && ch1.toInt! == turns else { isSolved = false; return }
            circles.remove(p); circles.remove(p2)
        }
    }
}
