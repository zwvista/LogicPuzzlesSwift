//
//  FussyWaiterGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FussyWaiterGameState: GridGameState<FussyWaiterGameMove> {
    var game: FussyWaiterGame {
        get { getGame() as! FussyWaiterGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FussyWaiterDocument.sharedInstance }
    var objArray = [FussyWaiterObject]()
    var pos2stateFood = [Position: AllowedObjectState]()
    var pos2stateDrink = [Position: AllowedObjectState]()
    
    override func copy() -> FussyWaiterGameState {
        let v = FussyWaiterGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FussyWaiterGameState) -> FussyWaiterGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FussyWaiterGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> FussyWaiterObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FussyWaiterObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout FussyWaiterGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && (move.isDrink ? self[p].drink : self[p].food) != move.obj else { return .invalid }
        if move.isDrink {
            self[p].drink = move.obj
        } else {
            self[p].food = move.obj
        }
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FussyWaiterGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && (move.isDrink ? game[p].drink : game[p].food) == " " else { return .invalid }
        let chMin: Character = move.isDrink ? "A" : "a"
        let chMax = Character(Unicode.Scalar(Int(chMin.asciiValue!) + rows)!)
        let o = move.isDrink ? self[p].drink : self[p].food
        move.obj = o == " " ? chMin : o == chMax ? " " : succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 15/Fussy Waiter

        Summary
        Won't give you what you asked for

        Description
        1. This restaurant has a peculiar waiter. Priding himself on a math
           degree, he is very fussy about how you order.
        2. Respecting university nutrition balance, he only accepts unique
           pairings of food and drinks.
        3. Thus, a type of food can be ordered along with the same drink only
           on a single table.
        4. Moreover, touting sudoku nutrition, he also maintains that each row
           and column of tables must have each food and drinks represented
           exactly once.
        5. He is indeed, very fussy.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2stateFood[p] = .normal
                pos2stateDrink[p] = .normal
            }
        }
        func f(arr: [(Position, Character)], pos2state: inout [Position: AllowedObjectState]) {
            var m = Dictionary(grouping: arr) { $0.1 }
            if m.keys.contains(" ") { isSolved = false }
            m = m.filter { ch, arr2 in ch != " " && arr2.count > 1 }
            if !m.isEmpty {
                isSolved = false
                for arr2 in m.values {
                    for (p, _) in arr2 {
                        pos2state[p] = .error
                    }
                }
            }
        }
        for r in 0..<rows {
            var foods = [(Position, Character)]()
            var drinks = [(Position, Character)]()
            for c in 0..<cols {
                let p = Position(r, c)
                foods.append((p, self[p].food))
                drinks.append((p, self[p].drink))
            }
            f(arr: foods, pos2state: &pos2stateFood)
            f(arr: drinks, pos2state: &pos2stateDrink)
        }
        for c in 0..<cols {
            var foods = [(Position, Character)]()
            var drinks = [(Position, Character)]()
            for r in 0..<rows {
                let p = Position(r, c)
                foods.append((p, self[p].food))
                drinks.append((p, self[p].drink))
            }
            f(arr: foods, pos2state: &pos2stateFood)
            f(arr: drinks, pos2state: &pos2stateDrink)
        }
    }
}
