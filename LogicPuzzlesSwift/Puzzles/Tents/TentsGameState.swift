//
//  TentsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TentsGameState: CellsGameState, TentsMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: TentsGame {
        get {return getGame() as! TentsGame}
        set {setGame(game: newValue)}
    }
    var objArray = [TentsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> TentsGameState {
        let v = TentsGameState(game: game)
        return setup(v: v)
    }
    func setup(v: TentsGameState) -> TentsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: TentsGame) {
        super.init(game: game);
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
    
    private func updateIsSolved() {
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
                    guard isValid(p: p2) else {continue}
                    switch self[p2] {
                    case .tree:
                        hasTree = true
                    case .tent:
                        hasTent = true
                    default:
                        continue
                    }
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
