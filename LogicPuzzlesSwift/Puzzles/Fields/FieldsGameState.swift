//
//  FieldsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FieldsGameState: GridGameState<FieldsGameMove> {
    var game: FieldsGame {
        get { getGame() as! FieldsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FieldsDocument.sharedInstance }
    var objArray = [FieldsObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> FieldsGameState {
        let v = FieldsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FieldsGameState) -> FieldsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FieldsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> FieldsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FieldsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout FieldsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FieldsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = o == .empty ? .meadow : o == .meadow ? .soil : .empty
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 1/Fields

        Summary
        Twice of the blessings of a Nurikabe

        Description
        1. Fill the board with either meadows or soil, creating a path of soil
           and a path of meadows, with the same rules for each of them.
        2. The path is continuous and connected horizontally or vertically, but
           cannot touch diagonally.
        3. The path can't form 2x2 squares.
        4. These type of paths are called Nurikabe.
    */
    private func updateIsSolved() {
        isSolved = true
        var meadows = [Position](), soils = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2state[p] = .normal
                switch self[p] {
                case .empty:
                    isSolved = false
                case .meadow:
                    meadows.append(p)
                case .soil:
                    soils.append(p)
                }
            }
        }
        // 3. The path can't form 2x2 squares.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                let square = FieldsGame.offset2.map { p + $0 }
                let objSet = Set(square.map { self[$0] })
                if objSet.count == 1 && objSet.first != .empty {
                    isSolved = false
                    for p in square {
                        pos2state[p] = .error
                    }
                }
            }
        }
        // 1. Fill the board with either meadows or soil, creating a path of soil
        //    and a path of meadows, with the same rules for each of them.
        // 2. The path is continuous and connected horizontally or vertically, but
        //    cannot touch diagonally.
        for fields in [meadows, soils] {
            let g = Graph()
            var pos2node = [Position: Node]()
            for p in fields {
                pos2node[p] = g.addNode(p.description)
            }
            for (p, node) in pos2node {
                for os in FieldsGame.offset {
                    let p2 = p + os
                    guard let node2 = pos2node[p2] else {continue}
                    g.addEdge(node, neighbor: node2)
                }
            }
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            if nodesExplored.count != pos2node.count { isSolved = false }
        }
    }
}
