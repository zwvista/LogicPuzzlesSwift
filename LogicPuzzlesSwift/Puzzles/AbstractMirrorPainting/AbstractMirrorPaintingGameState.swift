//
//  AbstractMirrorPaintingGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class AbstractMirrorPaintingGameState: GridGameState<AbstractMirrorPaintingGameMove> {
    var game: AbstractMirrorPaintingGame {
        get { getGame() as! AbstractMirrorPaintingGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { AbstractMirrorPaintingDocument.sharedInstance }
    var objArray = [AbstractMirrorPaintingObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> AbstractMirrorPaintingGameState {
        let v = AbstractMirrorPaintingGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: AbstractMirrorPaintingGameState) -> AbstractMirrorPaintingGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: AbstractMirrorPaintingGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<AbstractMirrorPaintingObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> AbstractMirrorPaintingObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> AbstractMirrorPaintingObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout AbstractMirrorPaintingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        for p2 in game.areas[game.pos2area[p]!] {
            self[p2] = move.obj
        }
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout AbstractMirrorPaintingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .painted
        case .painted: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .painted : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 4/Abstract Mirror Painting

        Summary
        Aliens, move over, the Next Trend is here!

        Description
        1. Diagonal mirrors are out, the new trend is orthogonal mirror abstract painting!
        2. You should paint areas that span two adjacent regions. The area is symmetrical with respect
           to the regions border.
        3. Numbers tell you how many tiles in that region are painted.
        4. Areas can't touch orthogonally.
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
        // 2. A number indicates how many painted tiles are adjacent to it.
        for (p, n2) in game.pos2hint {
            var rng = [Position]()
            var n1 = 0
            for os in AbstractMirrorPaintingGame.offset {
                let p2 = p + os
                guard game.isValid(p: p2) else {continue}
                switch self[p2] {
                case .painted:
                    n1 += 1
                case .empty:
                    rng.append(p2)
                default:
                    break
                }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete {
                isSolved = false
            } else if allowedObjectsOnly {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
        // 4. There can't be any 2*2 area of the same color(painted or empty).
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if AbstractMirrorPaintingGame.offset3.allSatisfy({ self[p + $0] == .painted }) ||
                   AbstractMirrorPaintingGame.offset3.allSatisfy({ self[p + $0] == .empty }) {
                    isSolved = false; return
                }
            }
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .painted { pos2node[p] = g.addNode(p.description) }
            }
        }
        for (p, node) in pos2node {
            for os in AbstractMirrorPaintingGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 3. The painted tiles form an orthogonally continuous area, like a
        // Nurikabe.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
