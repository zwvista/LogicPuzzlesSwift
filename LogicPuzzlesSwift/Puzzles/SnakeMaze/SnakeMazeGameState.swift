//
//  SnakeMazeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnakeMazeGameState: GridGameState<SnakeMazeGameMove> {
    var game: SnakeMazeGame {
        get { getGame() as! SnakeMazeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SnakeMazeDocument.sharedInstance }
    var objArray = [SnakeMazeObject]()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    var snakes = [[Position]]()

    override func copy() -> SnakeMazeGameState {
        let v = SnakeMazeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SnakeMazeGameState) -> SnakeMazeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SnakeMazeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<SnakeMazeObject>(repeating: SnakeMazeObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> SnakeMazeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> SnakeMazeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout SnakeMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game.pos2hint[p] == nil && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout SnakeMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game.pos2hint[p] == nil else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .snake1
        case .snake1: .snake2
        case .snake2: .snake3
        case .snake3: .snake4
        case .snake4: .snake5
        case .snake5: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .snake1 : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/Snake Maze

        Summary
        Find the snakes using the given hints.

        Description
        1. A Snake is a path of five tiles, numbered 1-2-3-4-5, where 1 is the head and 5 the tail.
           The snake's body segments are connected horizontally or vertically.
        2. A snake cannot see another snake or it would attack it. A snake sees straight in the
           direction 2-1, that is to say it sees in front of the number 1.
        3. A snake cannot touch another snake horizontally or vertically.
        4. Arrows show you the closest piece of Snake in that direction (before another arrow or the edge).
        5. Arrows with zero mean that there is no Snake in that direction.
        6. Arrows block snake sight and also block other arrows hints.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        var pos2snake = [Position: Int]()
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .forbidden {
                    self[p] = .empty
                } else if self[p].isSnake {
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        for (p, node) in pos2node {
            for os in SnakeMazeGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            // 1. A Snake is a path of five tiles, numbered 1-2-3-4-5, where 1 is the head and 5 the tail.
            //    The snake's body segments are connected horizontally or vertically.
            // 3. A snake cannot touch another snake horizontally or vertically.
            guard area.count == 5 && ((1...5).allSatisfy { n in
                area.contains { self[$0].value == n }
            }) else {
                for p in area { pos2stateAllowed[p] = .error }
                isSolved = false; continue
            }
            let snake = (1...5).map { n in
                area.first { self[$0].value == n }!
            }
            guard ((0..<4).allSatisfy { i in
                let os = snake[i] - snake[i + 1]
                return SnakeMazeGame.offset.contains(os)
            }) else {
                for p in area { pos2stateAllowed[p] = .error }
                isSolved = false; continue
            }
            for p in area { pos2stateAllowed[p] = .normal }
            let n = snakes.count
            snakes.append(snake)
            for p in snake { pos2snake[p] = n }
        }
        // 2. A snake cannot see another snake or it would attack it. A snake sees straight in the
        //    direction 2-1, that is to say it sees in front of the number 1.
        for snake in snakes {
            let os = snake[0] - snake[1]
            var p2 = snake[0] + os
            while isValid(p: p2) {
                if self[p2] == .empty && allowedObjectsOnly {
                    self[p2] = .forbidden
                } else if self[p2] == .hint {
                   break
                } else if self[p2].isSnake {
                    guard let n = pos2snake[p2] else {break}
                    for p in snakes[n] { pos2stateAllowed[p] = .error }
                    break
                }
                p2 += os
            }
        }
        // 4. Arrows show you the closest piece of Snake in that direction (before another arrow or the edge).
        // 5. Arrows with zero mean that there is no Snake in that direction.
        // 6. Arrows block snake sight and also block other arrows hints.
        for (p, hint) in game.pos2hint {
            let n2 = hint.num
            let os = SnakeMazeGame.offset[hint.dir]
            var n1 = 0
            var p2 = p + os
            while isValid(p: p2) {
                if self[p2] == .empty && n2 == 0 && allowedObjectsOnly {
                    self[p2] = .forbidden
                } else if self[p2] == .hint {
                    break
                } else if self[p2].isSnake {
                    n1 = self[p2].value
                    break
                }
                p2 += os
            }
            let s: HintState = n1 == n2 ? .complete : n1 == 0 ? .normal : .error
            pos2stateHint[p] = s
            if s != .complete { isSolved = false }
        }
    }
}
