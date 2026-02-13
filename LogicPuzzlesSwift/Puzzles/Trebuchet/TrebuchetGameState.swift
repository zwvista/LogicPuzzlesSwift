//
//  TrebuchetGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TrebuchetGameState: GridGameState<TrebuchetGameMove> {
    var game: TrebuchetGame {
        get { getGame() as! TrebuchetGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TrebuchetDocument.sharedInstance }
    var objArray = [TrebuchetObject]()
    
    override func copy() -> TrebuchetGameState {
        let v = TrebuchetGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TrebuchetGameState) -> TrebuchetGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TrebuchetGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TrebuchetObject>(repeating: .empty, count: rows * cols)
        for (p, _) in game.pos2hint { self[p] = .hint() }
        updateIsSolved()
    }
    
    subscript(p: Position) -> TrebuchetObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TrebuchetObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TrebuchetGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil, String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TrebuchetGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .target()
        case .target: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .target() : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 6/Trebuchet

        Summary
        Fire!

        Description
        1. On the board you can see some trebuchets.
        2. The number on a Trebuchet indicates the distance it shoots. Only one of
           the four directions can be marked with a target, the others should be empty.
        3. Two target cells must not be orthogonally adjacent.
        4. All of the non-targeted cells must be connected.
        5. Please note you can't target other trebuchets (yes it's a pointless war maybe)
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] {
                    self[r, c] = .empty
                }
            }
        }
        // 3. Two target cells must not be orthogonally adjacent.
        var targets = Set<Position>()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard case .target = self[p] else { continue }
                targets.insert(p)
                for os in TrebuchetGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2) else { continue }
                    switch self[p2] {
                    case .target:
                        isSolved = false
                        self[p] = .target(state: .error)
                        self[p2] = .target(state: .error)
                    case .empty:
                        if allowedObjectsOnly { self[p2] = .forbidden }
                    default:
                        break
                    }
                }
            }
        }
        // 4. All of the non-targeted cells must be connected.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].toString() != "target" else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in TrebuchetGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        for (p, _) in game.pos2hint {
            pos2node[p]!.neighbors = []
        }
        for node in g.nodes { node.visited = false }
        // 2. The number on a Trebuchet indicates the distance it shoots. Only one of
        //    the four directions can be marked with a target, the others should be empty.
        // 5. Please note you can't target other trebuchets (yes it's a pointless war maybe)
        for (p, _) in game.pos2hint {
            let possibleTargets = game.pos2targets[p]!
            let realTargets = possibleTargets.filter { self[$0].toString() == "target" }
            let emptyTargets = possibleTargets.filter { self[$0].toString() == "empty" }
            let n1 = realTargets.count
            let s: HintState = n1 < 1 ? .normal : n1 == 1 ? .complete : .error
            if s != .complete {
                isSolved = false
                for p2 in realTargets { self[p2] = .target(state: .error) }
            }
            self[p] = .hint(state: s)
            for p2 in realTargets { targets.remove(p2) }
            guard allowedObjectsOnly && s != .normal else {continue}
            for p2 in emptyTargets { self[p2] = .forbidden }
        }
        for p in targets { self[p] = .target(state: .error) }
    }
}
