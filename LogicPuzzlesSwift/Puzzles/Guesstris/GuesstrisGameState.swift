//
//  GuesstrisGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GuesstrisGameState: GridGameState<GuesstrisGameMove> {
    var game: GuesstrisGame {
        get { getGame() as! GuesstrisGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { GuesstrisDocument.sharedInstance }
    var objArray = [GridDotObject]()

    override func copy() -> GuesstrisGameState {
        let v = GuesstrisGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: GuesstrisGameState) -> GuesstrisGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: GuesstrisGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> GridDotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout GuesstrisGameMove) -> GameOperationType {
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let dir = move.dir, dir2 = (dir + 2) % 4
        let p = move.p, p2 = p + GuesstrisGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout GuesstrisGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[move.p][move.dir]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .line
        case .line: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .line : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 3/Guesstris

        Summary
        Encoded Tetris

        Description
        1. Divide the board in Tetrominoes (Tetris-like shapes of four cells).
        2. Each Tetromino contains two different symbols.
        3. Tetrominoes of the same shape have the same couple of symbols inside
           them, although not necessarily in the same positions.
        4. Tetrominoes with the same symbols can be rotated or mirrored.
    */
    private func updateIsSolved() {
        isSolved = true
        var areas = [[Position]]()
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
            }
        }
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for i in 0..<4 {
                    guard self[p + GuesstrisGame.offset2[i]][GuesstrisGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + GuesstrisGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { game.pos2char[$0] != " " }
            // 1. Divide the board in Tetrominoes (Tetris-like shapes of four cells).
            // 2. Each Tetromino contains two different symbols.
            if rng.count == 2 && area.count == 4 {
                areas.append(area)
            } else {
                isSolved = false; return
            }
        }
        // 3. Tetrominoes of the same shape have the same couple of symbols inside
        //    them, although not necessarily in the same positions.
        // 4. Tetrominoes with the same symbols can be rotated or mirrored.
        let area2D = Dictionary(grouping: areas) { area in
            var r1 = rows, c1 = cols
            for p in area {
                if r1 > p.row { r1 = p.row }
                if c1 > p.col { c1 = p.col }
            }
            let p1 = Position(r1, c1)
            let area2 = area.map { $0 - p1 }.sorted()
            return GuesstrisGame.tetrominoes.indices.first {
                GuesstrisGame.tetrominoes[$0].contains(area2)
            }!
        }.values
        if (!area2D.allSatisfy {
            let lst = $0.map { Array(Set($0.map { game.pos2char[$0]! }.filter { $0 != " " })).sorted() }
            return Set(lst).count == 1
        }) { isSolved = false }
    }
}
