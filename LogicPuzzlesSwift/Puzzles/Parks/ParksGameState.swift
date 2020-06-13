//
//  ParksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ParksGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: ParksGame {
        get {getGame() as! ParksGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: ParksDocument { ParksDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { ParksDocument.sharedInstance }
    var objArray = [ParksObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ParksGameState {
        let v = ParksGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ParksGameState) -> ParksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: ParksGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ParksObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
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
    
    /*
        iOS Game: Logic Games/Puzzle Set 1/Parks

        Summary
        Put one Tree in each Park, row and column.(two in bigger levels)

        Description
        1. In Parks, you have many differently coloured areas(Parks) on the board.
        2. The goal is to plant Trees, following these rules:
        3. A Tree can't touch another Tree, not even diagonally.
        4. Each park must have exactly ONE Tree.
        5. There must be exactly ONE Tree in each row and each column.
        6. Remember a Tree CANNOT touch another Tree diagonally,
           but it CAN be on the same diagonal line.
        7. Larger puzzles have TWO Trees in each park, each row and each column.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] {self[r, c] = .empty}
            }
        }
        // 3. A Tree can't touch another Tree, not even diagonally.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor() -> Bool {
                    for os in ParksGame.offset {
                        let p2 = p + os
                        if isValid(p: p2), case .tree = self[p2] {return true}
                    }
                    return false
                }
                switch self[p] {
                case .tree:
                    let s: AllowedObjectState = !hasNeighbor() ? .normal : .error
                    self[p] = .tree(state: s)
                    if s == .error {isSolved = false}
                case .empty, .marker:
                    if allowedObjectsOnly && hasNeighbor() {self[p] = .forbidden}
                default:
                    break
                }
            }
        }
        let n2 = game.treesInEachArea
        // 5. There must be exactly ONE Tree in each row.
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
                case .empty, .marker:
                    if n1 >= n2 && allowedObjectsOnly {self[r, c] = .forbidden}
                default:
                    break
                }
            }
        }
        // 5. There must be exactly ONE Tree in each column.
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
                case .empty, .marker:
                    if n1 >= n2 && allowedObjectsOnly {self[r, c] = .forbidden}
                default:
                    break
                }
            }
        }
        // 4. Each park must have exactly ONE Tree.
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
                case .empty, .marker:
                    if n1 >= n2 && allowedObjectsOnly {self[p] = .forbidden}
                default:
                    break
                }
            }
        }
    }
}
