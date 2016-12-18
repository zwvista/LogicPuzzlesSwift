//
//  ParksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ParksGameState: CellsGameState, ParksMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: ParksGame {
        get {return getGame() as! ParksGame}
        set {setGame(game: newValue)}
    }
    var objArray = [ParksObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ParksGameState {
        let v = ParksGameState(game: game)
        return setup(v: v)
    }
    func setup(v: ParksGameState) -> ParksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: ParksGame) {
        super.init(game: game);
        objArray = Array<ParksObject>(repeating: .empty, count: rows * cols)
    }
    
    subscript(p: Position) -> ParksObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> ParksObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout ParksGameMove) -> Bool {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout ParksGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: ParksObject) -> ParksObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tree(state: .normal)
            case .tree:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tree(state: .normal) : .empty
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
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .tree:
                    self[p] = .tree(state: .normal)
                default:
                    break
                }
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasTreeNeighbor() -> Bool {
                    for os in ParksGame.offset {
                        let p2 = p + os
                        guard isValid(p: p2) else {continue}
                        if case .tree = self[p2] {return true}
                    }
                    return false
                }
                switch self[p] {
                case let .tree(state):
                    self[p] = .tree(state: state == .normal && !hasTreeNeighbor() ? .normal : .error)
                case .forbidden:
                    break
                default:
                    guard allowedObjectsOnly && hasTreeNeighbor() else {continue}
                    self[p] = .forbidden
                }
            }
        }
        let n2 = game.treesInEachArea
        for r in 0..<rows {
            var n1 = 0
            for c in 0..<cols {
                if case .tree = self[r, c] {n1 += 1}
            }
            if n1 != n2 {isSolved = false}
            for c in 0..<cols {
                switch self[r, c] {
                case let .tree(state):
                    self[r, c] = .tree(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .forbidden:
                    break
                default:
                    if n1 == n2 && allowedObjectsOnly {self[r, c] = .forbidden}
                }
            }
        }
        for c in 0..<cols {
            var n1 = 0
            for r in 0..<rows {
                if case .tree = self[r, c] {n1 += 1}
            }
            if n1 != n2 {isSolved = false}
            for r in 0..<rows {
                switch self[r, c] {
                case let .tree(state):
                    self[r, c] = .tree(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .forbidden:
                    break
                default:
                    if n1 == n2 && allowedObjectsOnly {self[r, c] = .forbidden}
                }
            }
        }
        for a in game.areas {
            var n1 = 0
            for p in a {
                if case .tree = self[p] {n1 += 1}
            }
            if n1 != n2 {isSolved = false}
            for p in a {
                switch self[p] {
                case let .tree(state):
                    self[p] = .tree(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .forbidden:
                    break
                default:
                    if n1 == n2 && allowedObjectsOnly {self[p] = .forbidden}
                }
            }
        }
    }
}
