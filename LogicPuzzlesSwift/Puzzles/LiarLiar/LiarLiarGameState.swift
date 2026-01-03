//
//  LiarLiarGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LiarLiarGameState: GridGameState<LiarLiarGameMove> {
    var game: LiarLiarGame {
        get { getGame() as! LiarLiarGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LiarLiarDocument.sharedInstance }
    var objArray = [LiarLiarObject]()
    
    override func copy() -> LiarLiarGameState {
        let v = LiarLiarGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LiarLiarGameState) -> LiarLiarGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LiarLiarGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LiarLiarObject>(repeating: LiarLiarObject(), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> LiarLiarObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LiarLiarObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout LiarLiarGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game.pos2hint[p] == nil, String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout LiarLiarGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: LiarLiarObject) -> LiarLiarObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .marked()
            case .marked:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .marked() : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) && game.pos2hint[p] == nil else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 2/Liar Liar

        Summary
        Tiles on fire

        Description
        1. Mark some tiles according to these rules:
        2. Cells with numbers are never marked.
        3. A number in a cell indicates how many marked cells must be placed.
           adjacent to its four sides.
        4. However, in each region there is one (and only one) wrong number
           (it shows a wrong amount of marked cells).
        5. Two marked cells must not be orthogonally adjacent.
        6. All of the non-marked cells must be connected.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] { self[r, c] = .empty }
            }
        }
        // 3. A number in a cell indicates how many marked cells must be placed.
        //    adjacent to its four sides.
        for (p, n1) in game.pos2hint {
            let n2 = LiarLiarGame.offset.count {
                let p2 = p + $0
                return isValid(p: p2) && self[p2].toString() == "marked"
            }
            let s: HintState = n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
        }
        for area in game.areas {
            var nComplete = 0, nError = 0
            for p in area {
                if case .hint(state: let s) = self[p] {
                    switch s {
                    case .complete: nComplete += 1
                    default: nError += 1
                    }
                }
            }
            if nError != 1 { isSolved = false }
        }
        // 5. Two marked cells must not be orthogonally adjacent.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].toString() == "marked" else {continue}
                let rng = LiarLiarGame.offset.map { p + $0 }.filter { p in
                    return isValid(p: p) && self[p].toString() == "marked"
                }
                if rng.isEmpty {
                    self[p] = .marked()
                } else {
                    isSolved = false
                    self[p] = .marked(state: .error)
                    for p in rng {
                        self[p] = .marked(state: .error)
                    }
                }
                guard allowedObjectsOnly else {continue}
                for os in LiarLiarGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2), case .empty = self[p2] else {continue}
                    self[p2] = .forbidden
                }
            }
        }
        guard isSolved else {return}
        // 6. All of the non-marked cells must be connected.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].toString() != "marked" else {continue}
                let node = g.addNode(p.description)
                pos2node[p] = node
            }
        }
        for (p, node) in pos2node {
            for i in 0..<4 {
                let p2 = p + LiarLiarGame.offset[i]
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
