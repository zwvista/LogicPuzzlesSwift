//
//  SnakeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnakeGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: SnakeGame {
        get { getGame() as! SnakeGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: SnakeDocument { SnakeDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { SnakeDocument.sharedInstance }
    var objArray = [SnakeObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> SnakeGameState {
        let v = SnakeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SnakeGameState) -> SnakeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: SnakeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<SnakeObject>(repeating: SnakeObject(), count: rows * cols)
        for p in game.pos2snake {
            self[p] = .snake
        }
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> SnakeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> SnakeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func setObject(move: inout SnakeGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && !game.pos2snake.contains(p) && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout SnakeGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: SnakeObject) -> SnakeObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .snake
            case .snake:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .snake : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) && !game.pos2snake.contains(p) else { return false }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 16/Snake

        Summary
        Still lives inside your pocket-sized computer

        Description
        1. Complete the Snake, head to tail, inside the board.
        2. The two tiles given at the start are the head and the tail of the snake
           (it is irrelevant which is which).
        3. Numbers on the border tell you how many tiles the snake occupies in that
           row or column.
        4. The snake can't touch itself, not even diagonally.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if self[r, c] == .forbidden { self[r, c] = .empty }
            }
        }
        // 3. Numbers on the border tell you how many tiles the snake occupies in that row.
        for r in 0..<rows {
            let n2 = game.row2hint[r]
            guard n2 != -1 else {continue}
            var n1 = 0
            for c in 0..<cols {
                if self[r, c] == .snake { n1 += 1 }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
        }
        // 3. Numbers on the border tell you how many tiles the snake occupies in that column.
        for c in 0..<cols {
            let n2 = game.col2hint[c]
            guard n2 != -1 else {continue}
            var n1 = 0
            for r in 0..<rows {
                if self[r, c] == .snake { n1 += 1 }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                switch self[r, c] {
                case .empty, .marker:
                    if allowedObjectsOnly && (row2state[r] != .normal && game.row2hint[r] != -1 || col2state[c] != .normal && game.col2hint[c] != -1) { self[r, c] = .forbidden }
                default:
                    break
                }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] == .snake else {continue}
                let node = g.addNode(p.description)
                pos2node[p] = node
            }
        }
        for (p, node) in pos2node {
            for os in SnakeGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        for p in pos2node.keys {
            var (rngEmpty, rngSnake) = ([Position](), [Position]())
            for os in SnakeGame.offset {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                switch self[p2] {
                case .empty, .marker:
                    rngEmpty.append(p2)
                case .snake:
                    rngSnake.append(p2)
                default:
                    break
                }
            }
            // 2. The two tiles given at the start are the head and the tail of the snake.
            // 4. The snake can't touch itself, not even diagonally.
            let b = game.pos2snake.contains(p)
            let cnt = rngSnake.count
            if b && cnt >= 1 || !b && cnt >= 2 {
                for p2 in rngEmpty {
                    if allowedObjectsOnly { self[p2] = .forbidden }
                }
                if b && cnt > 1 || !b && cnt > 2 { isSolved = false }
            }
        }
    }
}
