//
//  SnakeominoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnakeominoGameState: GridGameState<SnakeominoGameMove> {
    var game: SnakeominoGame {
        get { getGame() as! SnakeominoGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SnakeominoDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()
    var snakes = [[Position]]()
    
    override func copy() -> SnakeominoGameState {
        let v = SnakeominoGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SnakeominoGameState) -> SnakeominoGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SnakeominoGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout SnakeominoGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == SnakeominoGame.PUZ_EMPTY && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout SnakeominoGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == SnakeominoGame.PUZ_EMPTY else { return .invalid }
        let o = self[p]
        move.obj = o == SnakeominoGame.PUZ_EMPTY ? 2 : o == game.nMax ? SnakeominoGame.PUZ_EMPTY : o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 4/Snake-omino

        Summary
        Snakes on a Plain

        Description
        1. Find Snakes by numbering them:
        2. A snake is a one-cell-wide path at least two cells long. A snake cannot touch itself,
           not even diagonally.
        3. A cell with a circle must be at one of the ends of a snake. A snake may contain one
           circled cell, two circled cells, or no circled cells at all.
        4. A cell with a number must be part of a snake with a length of exactly that number of cells.
        5. Two snakes of the same length must not be orthogonally adjacent.
        6. A cell with a cross cannot be an end of a snake.
        7. every cell in the board is part of a snake.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                // 7. every cell in the board is part of a snake.
                guard self[p] != SnakeominoGame.PUZ_EMPTY else { isSolved = false; continue }
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            let o = self[p]
            for os in SnakeominoGame.offset {
                let p2 = p + os
                guard isValid(p: p2) && self[p2] == o else {continue}
                g.addEdge(node, neighbor: pos2node[p2]!)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let snake = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            if ({
                // 2. A snake is at least two cells long.
                // 4. A cell with a number must be part of a snake with a length of exactly that number of cells.
                if !(snake.count >= 2 && snake.count == self[snake[0]]) { return false }
                var num2rng = [Int: [Position]]()
                for p in snake {
                    let cnt = SnakeominoGame.offset.count { snake.contains(p + $0) }
                    num2rng[cnt, default: []].append(p)
                }
                // 2. A snake is a one-cell-wide path.
                if (num2rng.contains { (num, _) in num > 2 }) { return false }
                let (rng1, rng2) = (num2rng[1], num2rng[2])
                // 2. A snake cannot touch itself, not even diagonally.
                // 3. A cell with a circle must be at one of the ends of a snake. A snake may contain one
                //   circled cell, two circled cells, or no circled cells at all.
                // 6. A cell with a cross cannot be an end of a snake.
                if (rng1?.contains {
                    game.pos2hint[$0] == SnakeominoGame.PUZ_NOT_END
                } ?? true || rng2?.contains {
                    game.pos2hint[$0] == SnakeominoGame.PUZ_END
                } ?? false) { return false }
                return true
            }()) {
                snakes.append(snake)
            } else {
                isSolved = false
            }
        }
    }
}
