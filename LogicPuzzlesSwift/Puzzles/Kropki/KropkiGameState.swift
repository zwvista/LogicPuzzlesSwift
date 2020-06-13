//
//  KropkiGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class KropkiGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: KropkiGame {
        get {return getGame() as! KropkiGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: KropkiDocument { return KropkiDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return KropkiDocument.sharedInstance }
    var objArray = [Int]()
    var pos2horzState = [Position: HintState]()
    var pos2vertState = [Position: HintState]()

    override func copy() -> KropkiGameState {
        let v = KropkiGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: KropkiGameState) -> KropkiGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2horzState = pos2horzState
        v.pos2vertState = pos2vertState
        return v
    }
    
    required init(game: KropkiGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> Int {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Int {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }

    func setObject(move: inout KropkiGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout KropkiGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) else {return false}
        let o = self[p]
        move.obj = (o + 1) % (cols + 1)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 6/Kropki

        Summary
        Fill the rows and columns with numbers, respecting the relations

        Description
        1. The Goal is to enter numbers 1 to board size once in every row and
           column.
        2. A Dot between two tiles give you hints about the two numbers:
        3. Black Dot - one number is twice the other.
        4. White Dot - the numbers are consecutive.
        5. Where the numbers are 1 and 2, there can be either a Black Dot(2 is
           1*2) or a White Dot(1 and 2 are consecutive).
        6. Please note that when two numbers are either consecutive or doubles,
           there MUST be a Dot between them!

        Variant
        7. In later 9*9 levels you will also have bordered and coloured areas,
           which must also contain all the numbers 1 to 9.
    */
    private func updateIsSolved() {
        isSolved = true
        // 1. The Goal is to enter numbers 1 to board size once in every row.
        for r in 0..<rows {
            let nums = Set<Int>((0..<cols).map{self[r, $0]})
            if nums.contains(0) || nums.count != cols {isSolved = false}
        }
        // 1. The Goal is to enter numbers 1 to board size once in every column.
        for c in 0..<cols {
            let nums = Set<Int>((0..<rows).map{self[$0, c]})
            if nums.contains(0) || nums.count != rows {isSolved = false}
        }
        // 7. In later 9*9 levels you will also have bordered and coloured areas,
        // which must also contain all the numbers 1 to 9.
        if game.bordered {
            for a in game.areas {
                let nums = Set<Int>(a.map{self[$0]})
                if nums.contains(0) || nums.count != a.count {isSolved = false}
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                for i in 0..<2 {
                    func setState(s: HintState) {
                        if i == 0 {
                            pos2horzState[p] = s
                        } else {
                            pos2vertState[p] = s
                        }
                    }
                    guard i == 0 && c != cols - 1 || i == 1 && r != rows - 1 else {continue}
                    var (n1, n2) = (self[p], self[r + i, c + 1 - i])
                    if n1 == 0 || n2 == 0 {setState(s: .normal); isSolved = false; continue}
                    if n1 > n2 {swap(&n1, &n2)}
                    let kh = (i == 0 ? game.pos2horzHint : game.pos2vertHint)[p]!
                    // 3. Black Dot - one number is twice the other.
                    // 4. White Dot - the numbers are consecutive.
                    // 5. Where the numbers are 1 and 2, there can be either a Black Dot(2 is
                    // 1*2) or a White Dot(1 and 2 are consecutive).
                    // 6. Please note that when two numbers are either consecutive or doubles,
                    // there MUST be a Dot between them!
                    let s: HintState =
                        n2 != n1 + 1 && n2 != n1 * 2 && kh == .none ||
                        n2 == n1 + 1 && kh == .consecutive ||
                        n2 == n1 * 2 && kh == .twice ? .complete : .error
                    setState(s: s)
                    if s != .complete {isSolved = false}
                }
            }
        }
    }
}
