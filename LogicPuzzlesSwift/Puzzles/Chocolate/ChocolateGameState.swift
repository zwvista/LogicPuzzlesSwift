//
//  ChocolateGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ChocolateGameState: GridGameState<ChocolateGameMove> {
    var game: ChocolateGame {
        get { getGame() as! ChocolateGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ChocolateDocument.sharedInstance }
    var objArray = [ChocolateObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ChocolateGameState {
        let v = ChocolateGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ChocolateGameState) -> ChocolateGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ChocolateGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ChocolateObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> ChocolateObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ChocolateObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ChocolateGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ChocolateGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .chocolate()
        case .chocolate: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .chocolate() : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 6/Chocolate

        Summary
        Yummy!

        Description
        1. Find some chocolate bars following these rules:
        2. A Chocolate bar is a rectangular or a square.
        3. Chocolate tiles form bars independently of the area borders.
        4. Chocolate bars must not be orthogonally adjacent.
        5. A tile with a number indicates how many tiles in the area must
           be chocolate.
        6. An area without number can have any number of tiles of chocolate.
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
        // 2. A Chocolate bar is a rectangular or a square.
        // 3. Chocolate tiles form bars independently of the area borders.
        // 4. Chocolate bars must not be orthogonally adjacent.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].toString() == "chocolate" else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in ChocolateGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let bar = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in bar {
                if r2 < p.row { r2 = p.row }
                if r1 > p.row { r1 = p.row }
                if c2 < p.col { c2 = p.col }
                if c1 > p.col { c1 = p.col }
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1
            let s: AllowedObjectState = rs * cs == bar.count ? .normal : .error
            if s != .normal { isSolved = false }
            for p in bar { self[p] = .chocolate(state: s) }
        }
        // 5. A tile with a number indicates how many tiles in the area must
        //    be chocolate.
        // 6. An area without number can have any number of tiles of chocolate.
        for area in game.areas {
            guard let pHint = area.first(where: { game.pos2hint[$0] != nil }) else {continue}
            let n2 = game.pos2hint[pHint]!
            let n1 = area.filter { self[$0].toString() == "chocolate" }.count
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s != .complete { isSolved = false }
            pos2state[pHint] = s
            guard allowedObjectsOnly && s != .normal else {continue}
            let empties = area.filter { self[$0].toString() == "empty" }
            for p in empties { self[p] = .forbidden }
        }
    }
}
