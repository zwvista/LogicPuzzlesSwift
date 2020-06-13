//
//  Square100GameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class Square100GameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: Square100Game {
        get {getGame() as! Square100Game}
        set {setGame(game: newValue)}
    }
    var gameDocument: Square100Document { Square100Document.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { Square100Document.sharedInstance }
    var objArray = [String]()
    var row2hint = [Int]()
    var col2hint = [Int]()
    
    override func copy() -> Square100GameState {
        let v = Square100GameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: Square100GameState) -> Square100GameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2hint = row2hint
        v.col2hint = col2hint
        return v
    }
    
    required init(game: Square100Game, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> String {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> String {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func setObject(move: inout Square100GameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout Square100GameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        let p = move.p
        guard isValid(p: p) else {return false}
        let n = self[p]
        var o = n[move.isRightPart ? 2 : 0]
        o =
            o == " " ? markerOption == .markerFirst ? "." : "0" :
            o == "." ? markerOption == .markerFirst ? "0" : " " :
            o == "9" ? markerOption == .markerLast ? "." : " " :
            succ(ch: o)
        if !move.isRightPart && o == "0" {o = "1"}
        move.obj = move.isRightPart ? n[0...1] + String(o) :
            String(o) + n[1...2]
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 10/Square100

        Summary
        Exactly one hundred

        Description
        1. You are given a 3*3 or 4*4 square with digits in it.
        2. You have to add digits to some (or all) tiles, in order to produce
           the sum of 100 for every row and column.
        3. You can add digits before or after the given one.
    */
    private func updateIsSolved() {
        isSolved = true
        func f(r: Int, c: Int) -> Int {
            let o = self[r, c]
            var n = o[1].toInt!
            // 3. You can add digits before or after the given one.
            if "0"..."9" ~= o[0] {n += o[0].toInt! * 10}
            if "0"..."9" ~= o[2] {n = n * 10 + o[2].toInt!}
            return n
        }
        // 2. You have to add digits to some (or all) tiles, in order to produce
        // the sum of 100 for every row.
        for r in 0..<rows {
            var n = 0
            for c in 0..<cols {
                n += f(r: r, c: c)
            }
            row2hint[r] = n
            if n != 100 {isSolved = false}
        }
        // 2. You have to add digits to some (or all) tiles, in order to produce
        // the sum of 100 for every column.
        for c in 0..<cols {
            var n = 0
            for r in 0..<rows {
                n += f(r: r, c: c)
            }
            col2hint[c] = n
            if n != 100 {isSolved = false}
        }
    }
}
