//
//  NooksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NooksGameState: GridGameState<NooksGameMove> {
    var game: NooksGame {
        get { getGame() as! NooksGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { NooksDocument.sharedInstance }
    var objArray = [NooksObject]()
    var pos2state = [Position: HintState]()
    var invalid2x2Squares = [Position]()

    override func copy() -> NooksGameState {
        let v = NooksGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NooksGameState) -> NooksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: NooksGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<NooksObject>(repeating: NooksObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> NooksObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> NooksObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout NooksGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game.pos2hint[p] == nil && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout NooksGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game.pos2hint[p] == nil else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .hedge
        case .hedge: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .hedge : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 17/Nooks

        Summary
        ...in a forest

        Description
        1. Fill some tiles with hedges, so that each number (where someone is playing hide and seek)
           finds itself in the nook.
        2. a Nook is a dead end, one tile wide, with a number in it.
        3. a Nook contains a number that shows you how many tiles can be seen in a straight line from
           there, including the tile itself.
        4. The resulting maze should be a single one-tile path connected horizontally or vertically
           where there are no 2x2 areas of the same type (hedge or path).
        5. No area in the maze can have the characteristics of a Nook without a number in it.
    */
    private func updateIsSolved() {
        isSolved = true
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
        // 1. Fill some tiles with hedges, so that each number (where someone is playing hide and seek)
        //    finds itself in the nook.
        // 2. a Nook is a dead end, one tile wide, with a number in it.
        // 5. No area in the maze can have the characteristics of a Nook without a number in it.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].isEmpty else {continue}
                let rng = NooksGame.offset.map { p + $0 }.filter { isValid(p: $0) && self[$0].isEmpty }
                guard rng.count == 1 else {continue}
                guard let n2 = game.pos2hint[p] else { isSolved = false; continue }
                // 3. a Nook contains a number that shows you how many tiles can be seen in a straight line from
                //    there, including the tile itself.
                let os = rng[0] - p
                var n1 = 1
                var p2 = p + os
                while isValid(p: p2) && self[p2].isEmpty {
                    n1 += 1
                    p2 += os
                }
                let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
                pos2state[p] = s
                if s != .complete { isSolved = false }
            }
        }
        // 4. there are no 2x2 areas of the same type (hedge or path).
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                let rng = NooksGame.offset2.map { p + $0 }
                let isOfSameType = rng.allSatisfy { self[$0].isHedge } || rng.allSatisfy { self[$0].isEmpty }
                if isOfSameType { invalid2x2Squares.append(p + Position.SouthEast); isSolved = false }
            }
        }
        // 4. The resulting maze should be a single one-tile path connected horizontally or vertically
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].isEmpty else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in DesertDunesGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
