//
//  SuspendedGravityGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SuspendedGravityGameState: GridGameState<SuspendedGravityGameMove> {
    var game: SuspendedGravityGame {
        get { getGame() as! SuspendedGravityGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SuspendedGravityDocument.sharedInstance }
    var objArray = [SuspendedGravityObject]()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    
    override func copy() -> SuspendedGravityGameState {
        let v = SuspendedGravityGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SuspendedGravityGameState) -> SuspendedGravityGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SuspendedGravityGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<SuspendedGravityObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> SuspendedGravityObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> SuspendedGravityObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout SuspendedGravityGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout SuspendedGravityGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .stone
        case .stone: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .stone : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 1/Suspended Gravity

        Summary
        Falling Blocks

        Description
        1. Each region contains the number of stones, which can be indicated by a number.
        2. Regions without a number contain at least one stone.
        3. Stones inside a region are all connected either vertically or horizontally.
        4. Stones in two adjacent regions cannot touch horizontally or vertically.
        5. Lastly, if we apply gravity to the puzzle and the stones fall down to
           the bottom of the board they fit together exactly and cover the bottom
           half of the board.
        6. Think "Tetris": all the blocks will fall as they are
           (they won't break into single stones)
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        // 3. Stones inside a region are all connected either vertically or horizontally.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .stone:
                    pos2stateAllowed[p] = .normal
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
                if game.pos2hint[p] != nil {
                    pos2stateHint[p] = .normal
                }
            }
        }
        for (p, node) in pos2node {
            for os in SuspendedGravityGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        var area2blocks = [Int: [[Position]]]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let block = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            // 4. Stones in two adjacent regions cannot touch horizontally or vertically.
            let nArea = game.pos2area[block[0]]!
            guard block.allSatisfy({ game.pos2area[$0] == nArea }) else {
                for p in block { pos2stateAllowed[p] = .error }
                isSolved = false
                continue
            }
            area2blocks[nArea, default: []].append(block)
        }
        // 3. Stones inside a region are all connected either vertically or horizontally.
        for nArea in game.areas.indices {
            // 2. Regions without a number contain at least one stone.
            guard let blocks = area2blocks[nArea] else { isSolved = false; continue }
            if blocks.count != 1 {
                for block in blocks {
                    for p in block { pos2stateAllowed[p] = .error }
                }
                isSolved = false
            }
            // 4. Stones in two adjacent regions cannot touch horizontally or vertically.
            if allowedObjectsOnly {
                let rng = Set(blocks.flatMap { $0 }
                    .flatMap { p in SuspendedGravityGame.offset.map { p + $0 } }
                    .filter { isValid(p: $0) && self[$0] == .empty && game.pos2area[$0] != nArea })
                for p in rng { self[p] = .forbidden }
            }
            // 1. Each region contains the number of stones, which can be indicated by a number.
            let n1 = blocks.reduce(0) { $0 + $1.count }
            guard let pHint = game.area2hint[nArea] else {continue}
            let n2 = game.pos2hint[pHint]!
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2stateHint[pHint] = s
            if s != .complete { isSolved = false }
        }
        guard isSolved else {return}
        // 5. Lastly, if we apply gravity to the puzzle and the stones fall down to
        //    the bottom of the board they fit together exactly and cover the bottom
        //    half of the board.
        // 6. Think "Tetris": all the blocks will fall as they are
        //    (they won't break into single stones)
    }
}
