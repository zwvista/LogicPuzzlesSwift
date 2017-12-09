//
//  DisconnectFourGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DisconnectFourGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: DisconnectFourGame {
        get {return getGame() as! DisconnectFourGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: DisconnectFourDocument { return DisconnectFourDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return DisconnectFourDocument.sharedInstance }
    var objArray = [Character]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> DisconnectFourGameState {
        let v = DisconnectFourGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: DisconnectFourGameState) -> DisconnectFourGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: DisconnectFourGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> Character {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Character {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout DisconnectFourGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p), game[p] == " ", self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout DisconnectFourGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p), game[p] == " " else {return false}
        let o = self[p]
        move.obj = o == " " ? "Y" : o == "Y" ? "R" : " "
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
        var chLast: Character = " "
        var trees = [Position]()
        func checkTrees() {
            if trees.count > 3 {
                isSolved = false
                for p in trees {
                    pos2state[p] = .error
                }
            }
            trees.removeAll()
        }
        for r in 0..<rows {
            chLast = " "
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = self[p]
                if ch != chLast {
                    checkTrees()
                    chLast = ch
                }
                if ch != " " {trees.append(p)}
            }
            checkTrees()
        }
        for c in 0..<cols {
            chLast = " "
            for r in 0..<rows {
                let p = Position(r, c)
                let ch = self[p]
                if ch != chLast {
                    checkTrees()
                    chLast = ch
                }
                if ch != " " {trees.append(p)}
            }
            checkTrees()
        }
    }
}
