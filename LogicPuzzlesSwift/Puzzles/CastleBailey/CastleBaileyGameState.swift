//
//  CastleBaileyGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CastleBaileyGameState: GridGameState<CastleBaileyGame, CastleBaileyDocument, CastleBaileyGameMove> {
    override var gameDocument: CastleBaileyDocument { CastleBaileyDocument.sharedInstance }
    var objArray = [CastleBaileyObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> CastleBaileyGameState {
        let v = CastleBaileyGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CastleBaileyGameState) -> CastleBaileyGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: CastleBaileyGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CastleBaileyObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> CastleBaileyObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CastleBaileyObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CastleBaileyGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout CastleBaileyGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: CastleBaileyObject) -> CastleBaileyObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .wall
            case .wall:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .wall : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else { return false }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 13/Castle Bailey

        Summary
        Towers, keeps and curtain walls

        Description
        1. A very convoluted Medieval Architect devised a very weird Bailey
           (or Ward, the inner area contained in the Outer Walls of a Castle).
        2. He deployed quite a few towers (the circles) and put a number on
           top of each one.
        3. The number tells you how many pieces (squares) of wall it touches.
        4. So the number can go from 0 (no walls around the tower) to 4 (tower
           entirely surrounded by walls).
        5. Board borders don't count as walls, so there you'll have two walls
           at most (or one in corners).
        6. To facilitate movement in the castle, the Bailey must have a single
           continuous area (Garden).
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .forbidden { self[p] = .empty }
            }
        }
        for (p, n2) in game.pos2hint {
            var n1 = 0
            var rng = [Position]()
            for os  in CastleBaileyGame.offset2 {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                switch self[p2] {
                case .empty, .marker:
                    rng.append(os)
                case .wall:
                    n1 += 1
                default:
                    break
                }
            }
            // 3. The number tells you how many pieces (squares) of wall it touches.
            // 4. So the number can go from 0 (no walls around the tower) to 4 (tower
            // entirely surrounded by walls).
            // 5. Board borders don't count as walls, so there you'll have two walls
            // at most (or one in corners).
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
            if s != .normal && allowedObjectsOnly {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
        if !isSolved {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] != .wall { pos2node[p] = g.addNode(p.description) }
            }
        }
        for (p, node) in pos2node {
            for os in CastleBaileyGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(node, neighbor: node2)
                }
            }
        }
        // 6. To facilitate movement in the castle, the Bailey must have a single
        // continuous area (Garden).
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
