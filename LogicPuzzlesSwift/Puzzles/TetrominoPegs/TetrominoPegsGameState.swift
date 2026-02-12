//
//  TetrominoPegsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TetrominoPegsGameState: GridGameState<TetrominoPegsGameMove> {
    var game: TetrominoPegsGame {
        get { getGame() as! TetrominoPegsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TetrominoPegsDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var tetros = [TetrominoPegsObject]()
    
    override func copy() -> TetrominoPegsGameState {
        let v = TetrominoPegsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TetrominoPegsGameState) -> TetrominoPegsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TetrominoPegsGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout TetrominoPegsGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + TetrominoPegsGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout TetrominoPegsGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            default:
                return o
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 5/Tetromino Pegs

        Summary
        Stuck in Tetris

        Description
        1. Divide the board into Tetrominoes, area of exactly four tiles, of a shape
           like the pieces of Tetris, that is: L, I, T, S or O.
        2. Wood cells are fixed pegs and aren't part of Tetrominoes.
        3. Tetrominoes may be rotated or mirrored.
        4. Two Tetrominoes sharing an edge must be different.
    */
    private func updateIsSolved() {
        isSolved = true
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
                    guard self[p + TetrominoPegsGame.offset2[i]][TetrominoPegsGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + TetrominoPegsGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            // 2. Wood cells are fixed pegs and aren't part of Tetrominoes.
            if area.count == 1 && game.pegs.contains(area[0]) {continue}
            guard area.count == 4 else { isSolved = false; continue }
            // 1. Divide the board into Tetrominoes, area of exactly four tiles, of a shape
            //    like the pieces of Tetris, that is: L, I, T, S or O.
            // 3. Tetrominoes may be rotated or mirrored.
            var r1 = rows, c1 = cols
            for p in area {
                if r1 > p.row { r1 = p.row }
                if c1 > p.col { c1 = p.col }
            }
            let p1 = Position(r1, c1)
            let area2 = area.map { $0 - p1 }.sorted()
            let n = TetrominoPegsGame.tetrominoes.indices.first {
                TetrominoPegsGame.tetrominoes[$0].contains(area2)
            }!
            tetros.append(TetrominoPegsObject(rng: area, kind: n))
        }
        // 4. Two Tetrominoes sharing an edge must be different.
        if (tetros.indices.contains { index in
            let t = tetros[index]
            return t.rng.contains { p in
                TetrominoPegsGame.offset.contains {
                    let p2 = p + $0
                    guard let index2 = (tetros.indices.first {
                        tetros[$0].rng.contains(p2)
                    }), index2 != index else { return false }
                    return tetros[index2].kind == t.kind
                }
            }
        }) { isSolved = false }
    }
}
