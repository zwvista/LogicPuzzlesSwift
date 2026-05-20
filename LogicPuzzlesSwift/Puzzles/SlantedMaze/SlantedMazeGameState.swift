//
//  SlantedMazeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SlantedMazeGameState: GridGameState<SlantedMazeGameMove> {
    var game: SlantedMazeGame {
        get { getGame() as! SlantedMazeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SlantedMazeDocument.sharedInstance }
    var objArray = [SlantedMazeObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> SlantedMazeGameState {
        let v = SlantedMazeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SlantedMazeGameState) -> SlantedMazeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SlantedMazeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<SlantedMazeObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> SlantedMazeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> SlantedMazeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout SlantedMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout SlantedMazeGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: markerOption)
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .wall
        case .wall: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .wall : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 6/Slanted Maze

        Summary
        Maze of Slants!

        Description
        1. Fill the board with diagonal lines (Slants), following the hints at
           the intersections.
        2. Every number tells you how many Slants (diagonal lines) touch that
           point. So, for example, a 4 designates an X pattern around it.
        3. The Mazes or paths the Slants will form will usually branch off many
           times, but can also end abruptly. Also all the Slants don't need to
           be all connected.
        4. However, you must ensure that they don't form a closed loop anywhere.
           This also means very big loops, not just 2*2.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .forbidden { self[p] = .empty }
            }
        }
        for (p, n2) in game.pos2hint {
            var n1 = 0
            var rng = [Position]()
            for os in SlantedMazeGame.offset2 {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                switch self[p2] {
                case .empty, .marker:
                    rng.append(os)
                case .wall:
                    n1 += 1
                default:
                    break
                }
            }
            // 3. The number tells you how many pieces (squares) of wall it touches.
            // 4. So the number can go from 0 (no walls around the tower) to 4 (tower
            // entirely surrounded by walls).
            // 5. Board borders don't count as walls, so there you'll have two walls
            // at most (or one in corners).
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
            if s != .normal && allowedObjectsOnly {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
        if !isSolved {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] != .wall { pos2node[p] = g.addNode(p.description) }
            }
        }
        for (p, node) in pos2node {
            for os in SlantedMazeGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(node, neighbor: node2)
                }
            }
        }
        // 6. To facilitate movement in the castle, the Bailey must have a single
        // continuous area (Garden).
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
