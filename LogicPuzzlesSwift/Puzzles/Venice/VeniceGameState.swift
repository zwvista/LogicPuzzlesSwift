//
//  VeniceGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class VeniceGameState: GridGameState<VeniceGameMove> {
    var game: VeniceGame {
        get { getGame() as! VeniceGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { VeniceDocument.sharedInstance }
    var objArray = [VeniceObject]()
    var pos2state = [Position: HintState]()
    var invalid2x2Squares = [Position]()

    override func copy() -> VeniceGameState {
        let v = VeniceGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: VeniceGameState) -> VeniceGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: VeniceGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<VeniceObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> VeniceObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> VeniceObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout VeniceGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != .hint, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout VeniceGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != .hint else { return .invalid }
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: VeniceObject) -> VeniceObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .water
            case .water:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .water : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Venice

        Summary
        Gondolas and Canals

        Description
        1. Each number identifies a house in Venice.
        2. The number on it tells you how many tiles of Canal that house sees,
           horizontally and vertically in the four directions, up to the next empty cell.
        3. The Canal forms a single connected area which cannot contain a 2x2 area
           (like a Nurikabe).
    */
    private func updateIsSolved() {
        isSolved = true
        // 3. The Canal cannot contain a 2x2 area (like a Nurikabe).
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if VeniceGame.offset2.map({ p + $0 }).allSatisfy({ self[$0] == .water }) { invalid2x2Squares.append(p + Position.SouthEast); isSolved = false
                }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .water {
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        // 1. Each number identifies a house in Venice.
        // 2. The number on it tells you how many tiles of Canal that house sees,
        //    horizontally and vertically in the four directions, up to the next empty cell.
        for (p, n2) in game.pos2hint {
            var n1 = 0
            for i in 0..<4 {
                let os = VeniceGame.offset[i]
                var p2 = p + os
                while game.isValid(p: p2) {
                    guard self[p2] == .water else {break}
                    n1 += 1
                    p2 += os
                }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
        }
        guard isSolved else {return}
        for (p, node) in pos2node {
            for os in VeniceGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 3. The Canal forms a single connected area
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
