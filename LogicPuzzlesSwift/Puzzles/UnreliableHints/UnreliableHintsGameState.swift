//
//  UnreliableHintsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class UnreliableHintsGameState: GridGameState<UnreliableHintsGameMove> {
    var game: UnreliableHintsGame {
        get { getGame() as! UnreliableHintsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { UnreliableHintsDocument.sharedInstance }
    var objArray = [UnreliableHintsObject]()
    var row2hint = [String]()
    var col2hint = [String]()
    
    override func copy() -> UnreliableHintsGameState {
        let v = UnreliableHintsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: UnreliableHintsGameState) -> UnreliableHintsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2hint = row2hint
        v.col2hint = col2hint
        return v
    }
    
    required init(game: UnreliableHintsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<UnreliableHintsObject>(repeating: UnreliableHintsObject(), count: rows * cols)
        row2hint = Array<String>(repeating: "", count: rows)
        col2hint = Array<String>(repeating: "", count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> UnreliableHintsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> UnreliableHintsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout UnreliableHintsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout UnreliableHintsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .normal: markerOption == .markerFirst ? .marker : .darken
        case .darken: markerOption == .markerLast ? .marker : .normal
        case .marker: markerOption == .markerFirst ? .darken : .normal
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 5/Unreliable hints

        Summary
        Can't trust them all

        Description
        1. Shade some tiles according to the following rules:
        2. Shaded tiles must not be orthogonally connected.
        3. You can shade tiles with arrows and numbers.
        4. All tiles which are not shaded must form an orthogonally continuous area.
        5. A cell containing a number and an arrow tells you how many tiles are shaded
           in that direction.
        6. However not all tiles that are shaded tell you lies.
    */
    private func updateIsSolved() {
        isSolved = true
        var chars = ""
        // 1. The goal is to shade squares so that a number appears only once in a
        // row.
        for r in 0..<rows {
            chars = ""
            row2hint[r] = ""
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] != .darken else {continue}
                let ch = game[p]
                if chars.contains(String(ch)) {
                    isSolved = false
                    row2hint[r].append(ch)
                } else {
                    chars.append(ch)
                }
            }
        }
        // 1. The goal is to shade squares so that a number appears only once in a
        // column.
        for c in 0..<cols {
            chars = ""
            col2hint[c] = ""
            for r in 0..<rows {
                let p = Position(r, c)
                guard self[p] != .darken else {continue}
                let ch = game[p]
                if chars.contains(String(ch)) {
                    isSolved = false
                    col2hint[c].append(ch)
                } else {
                    chars.append(ch)
                }
            }
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngDarken = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .darken:
                    rngDarken.append(p)
                default:
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        // 2. While doing that, you must take care that shaded squares don't touch
        // horizontally or vertically between them.
        for p in rngDarken {
            for os in UnreliableHintsGame.offset {
                let p2 = p + os
                guard !rngDarken.contains(p2) else { isSolved = false; return }
            }
        }
        for (p, node) in pos2node {
            for os in UnreliableHintsGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 3. In the end all the un-shaded squares must form a single continuous area.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
