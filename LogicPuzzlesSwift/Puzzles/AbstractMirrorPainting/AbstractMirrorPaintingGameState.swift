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
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()

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
                pos2stateAllowed[p] = .normal
                if self[p] == .forbidden { self[p] = .empty }
            }
        }
        // 3. Numbers tell you how many tiles in that region are painted.
        for (p, n2) in game.pos2hint {
            let area = game.areas[game.pos2area[p]!]
            let n1 = area.count { self[$0] == .painted }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s != .complete { isSolved = false }
            pos2stateHint[p] = s
            if allowedObjectsOnly && s != .normal {
                for p2 in area where self[p2] == .empty || self[p2] == .marker {
                    self[p2] = .forbidden
                }
            }
        }
        // 2. You should paint areas that span two adjacent regions. The area is symmetrical with respect
        //    to the regions border.
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
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let painting = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let areaSet = Set(painting.map { game.pos2area[$0]! }).sorted()
            if areaSet.count != 2 {
                isSolved = false
                for p in painting { pos2stateAllowed[p] = .error }
            } else {
                let (areaId1, areaId2) = (areaSet.first!, areaSet.last!)
                let painting1 = painting.filter { game.pos2area[$0] == areaId1 }
                let painting2 = painting.filter { game.pos2area[$0] == areaId2 }
                let mirrors = game.mirrors.filter { $0.areaId1 == areaId1 && $0.areaId2 == areaId2 }
                if (!mirrors.contains {
                    let (p1, p2) = ($0.p1, $0.p2)
                    return painting1.allSatisfy {
                        painting2.contains($0 - p1 + p2)
                    }
                }) {
                    isSolved = false
                    for p in painting { pos2stateAllowed[p] = .error }
                }
            }
        }
    }
}
