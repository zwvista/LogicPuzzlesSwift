//
//  TentsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TentsGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: TentsGame {
        get {return getGame() as! TentsGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: TentsDocument { return TentsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return TentsDocument.sharedInstance }
    var objArray = [TentsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> TentsGameState {
        let v = TentsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TentsGameState) -> TentsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: TentsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TentsObject>(repeating: TentsObject(), count: rows * cols)
        for p in game.pos2tree {
            self[p] = .tree
        }
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> TentsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> TentsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout TentsGameMove) -> Bool {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout TentsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: TentsObject) -> TentsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tent(state: .normal)
            case .tent:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tent(state: .normal) : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 1/Tents

        Summary
        Each camper wants to put his Tent under the shade of a Tree. But he also
        wants his privacy!

        Description
        1. The board represents a camping field with many Trees. Campers want to set
           their Tent in the shade, horizontally or vertically adjacent to a Tree(not
           diagonally).
        2. At the same time they need their privacy, so a Tent can't have any other
           Tents near them, not even diagonally.
        3. The numbers on the borders tell you how many Tents there are in that row
           or column.
        4. Finally, each Tree has at least one Tent touching it, horizontally or
           vertically.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if case .tent = self[r, c] {n1 += 1}
            }
            row2state[r] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if case .tent = self[r, c] {n1 += 1}
            }
            col2state[c] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] {self[r, c] = .empty}
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if case .tree = self[p] {continue}
                var (hasTree, hasTent) = (false, false)
                for os in TentsGame.offset {
                    let p2 = p + os
                    if isValid(p: p2), case .tree = self[p2] {hasTree = true}
                }
                for os in TentsGame.offset2 {
                    let p2 = p + os
                    if isValid(p: p2), case .tent = self[p2] {hasTent = true}
                }
                switch self[p] {
                case .tent:
                    self[p] = .tent(state: (hasTree, hasTent) == (true, false) ? .normal : .error)
                    if (hasTree, hasTent) != (true, false) {isSolved = false}
                case .empty, .marker:
                    guard allowedObjectsOnly else {break}
                    if col2state[c] != .normal || row2state[r] != .normal || !hasTree || hasTent {self[p] = .forbidden}
                default:
                    break
                }
            }
        }
    }
}
