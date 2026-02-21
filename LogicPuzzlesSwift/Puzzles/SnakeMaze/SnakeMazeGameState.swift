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
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout SnakeMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .normal: markerOption == .markerFirst ? .marker : .shaded
        case .shaded: markerOption == .markerLast ? .marker : .normal
        case .marker: markerOption == .markerFirst ? .shaded : .normal
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
        isSolved = true
        // 3. You can shade tiles with arrows and numbers.
        // 5. A cell containing a number and an arrow tells you how many tiles are shaded
        //    in that direction.
        // 6. However not all tiles that are shaded tell you lies.
        for (p, hint) in game.pos2hint {
            guard !self[p].isShaded else {
                pos2stateHint[p] = .complete
                continue
            }
            let n2 = hint.num
            let os = SnakeMazeGame.offset[hint.dir]
            var n1 = 0
            var p2 = p + os
            while isValid(p: p2) {
                if self[p2].isShaded { n1 += 1 }
                p2 += os
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2stateHint[p] = s
            if s != .complete { isSolved = false }
        }
        // 2. Shaded tiles must not be orthogonally connected.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].isShaded else { continue }
                let s: AllowedObjectState = (!SnakeMazeGame.offset.contains {
                    let p2 = p + $0
                    return isValid(p: p2) && self[p2].isShaded
                }) ? .normal : .error
                pos2stateAllowed[p] = s
                if s == .error { isSolved = false }
            }
        }
        guard isSolved else {return}
        // 4. All tiles which are not shaded must form an orthogonally continuous area.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if !self[p].isShaded {
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
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
