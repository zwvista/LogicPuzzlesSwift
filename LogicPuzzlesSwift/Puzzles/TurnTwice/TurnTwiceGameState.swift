//
//  TurnTwiceGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TurnTwiceGameState: GridGameState<TurnTwiceGameMove> {
    var game: TurnTwiceGame {
        get { getGame() as! TurnTwiceGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TurnTwiceDocument.sharedInstance }
    var objArray = [TurnTwiceObject]()
    
    override func copy() -> TurnTwiceGameState {
        let v = TurnTwiceGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TurnTwiceGameState) -> TurnTwiceGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TurnTwiceGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> TurnTwiceObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TurnTwiceObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TurnTwiceGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), case .empty = game[p], String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TurnTwiceGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: markerOption)
        func f(o: TurnTwiceObject) -> TurnTwiceObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .wall()
            case .wall:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .signpost() : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p), case .empty = game[p] else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 15/Turn Twice

        Summary
        Think and Turn Twice (or more)

        Description
        1. In an effort to complicate signposts, you're given the task to have
           signposts reach other by no less than two turns.
        2. In other words, you have to place walls on the board so that a maze of
           signposts is formed. In this maze:
        3. In order to go from one signpost to the other, you have to turn at least
           twice.
        4. Walls can't touch horizontally or vertically.
        5. All the signposts and empty spaces must form an orthogonally continuous
           area.
    */
    private func updateIsSolved() {
        func isEmpty(p: Position) -> Bool {
            if case .wall = self[p] { return false }
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
                    self[p] = .signpost()
                case .wall:
                    self[p] = .wall()
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
            for os in TurnTwiceGame.offset {
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
                self[p1] = .signpost(state: .error)
                self[p2] = .signpost(state: .error)
            }
        }
        
        // 4. Walls can't touch horizontally or vertically.
        for p in walls {
            for os in TurnTwiceGame.offset {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                switch self[p2] {
                case .wall:
                    isSolved = false
                    self[p] = .wall(state: .error)
                    self[p2] = .wall(state: .error)
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
