//
//  FieldsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FieldsGameState: GridGameState<FieldsGameMove> {
    var game: FieldsGame {
        get { getGame() as! FieldsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FieldsDocument.sharedInstance }
    var objArray = [FieldsObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> FieldsGameState {
        let v = FieldsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FieldsGameState) -> FieldsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: FieldsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> FieldsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FieldsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout FieldsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FieldsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = o == .empty ? .yellow : o == .yellow ? .red : .empty
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 11/Disconnect Four

        Summary
        Win by not winning!

        Description
        1. The opposite of the famous game 'Connect Four', where you must line
           up four tokens of the same colour.
        2. In this puzzle you have to ensure that there are no more than three
           tokens of the same colour lined up horizontally, vertically or
           diagonally.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        var oLast: FieldsObject = .empty
        var tokens = [Position]()
        func checkTokens() {
            if tokens.count > 3 {
                isSolved = false
                for p in tokens {
                    pos2state[p] = .error
                }
            }
            tokens.removeAll()
        }
        for r in 0..<rows {
            oLast = .empty
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                if o != oLast {
                    checkTokens()
                    oLast = o
                }
                if o == .empty {
                    isSolved = false
                } else {
                    tokens.append(p)
                }
            }
            checkTokens()
        }
        for c in 0..<cols {
            oLast = .empty
            for r in 0..<rows {
                let p = Position(r, c)
                let o = self[p]
                if o != oLast {
                    checkTokens()
                    oLast = o
                }
                if o == .empty {
                    isSolved = false
                } else {
                    tokens.append(p)
                }
            }
            checkTokens()
        }
    }
}
