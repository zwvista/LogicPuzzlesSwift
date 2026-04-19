//
//  TheGreyLabyrinthGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TheGreyLabyrinthGameState: GridGameState<TheGreyLabyrinthGameMove> {
    var game: TheGreyLabyrinthGame {
        get { getGame() as! TheGreyLabyrinthGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TheGreyLabyrinthDocument.sharedInstance }
    var objArray = [TheGreyLabyrinthObject]()
    var pos2state = [Position: AllowedObjectState]()
    
    override func copy() -> TheGreyLabyrinthGameState {
        let v = TheGreyLabyrinthGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TheGreyLabyrinthGameState) -> TheGreyLabyrinthGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TheGreyLabyrinthGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> TheGreyLabyrinthObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TheGreyLabyrinthObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TheGreyLabyrinthGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TheGreyLabyrinthGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .wall
        case .wall: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .signpost : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 3/The Grey Labyrinth

        Summary
        Maze Curator

        Description
        1. Find the walls that divide the board in a Labyrinth.
        2. The Labyrinth must have these rules:
        3. Walls can't touch each other orthogonally.
        4. From any location, there must only be one route to the treasure.
        5. You must follow the arrows, where present.
    */
    private func updateIsSolved() {
        func isEmpty(p: Position) -> Bool {
            if self[p] == .wall { return false }
            return true
        }
        
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        var walls = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .signpost:
                    pos2state[p] = .normal
                case .wall:
                    pos2state[p] = .normal
                    walls.append(p)
                default:
                    break
                }
                if isEmpty(p: p) {
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        for (p, node) in pos2node {
            for os in TheGreyLabyrinthGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 5. All the signposts and empty spaces must form an orthogonally continuous
        // area.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        
        // 3. In order to go from one signpost to the other, you have to turn at least
        // twice.
        for (p1, p2, path) in game.paths {
            if path.allSatisfy({ isEmpty(p: $0) }) {
                isSolved = false
                pos2state[p1] = .error
                pos2state[p2] = .error
            }
        }
        
        // 4. Walls can't touch horizontally or vertically.
        for p in walls {
            for os in TheGreyLabyrinthGame.offset {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                switch self[p2] {
                case .wall:
                    isSolved = false
                    pos2state[p] = .error
                    pos2state[p2] = .error
                case .empty:
                    if allowedObjectsOnly {
                        self[p2] = .forbidden
                    }
                default :
                    break
                }
            }
        }
    }
}
