//
//  UnreliableHintsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class UnreliableHintsGameState: GridGameState<UnreliableHintsGameMove> {
    var game: UnreliableHintsGame {
        get { getGame() as! UnreliableHintsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { UnreliableHintsDocument.sharedInstance }
    var objArray = [UnreliableHintsObject]()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()

    override func copy() -> UnreliableHintsGameState {
        let v = UnreliableHintsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: UnreliableHintsGameState) -> UnreliableHintsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: UnreliableHintsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<UnreliableHintsObject>(repeating: UnreliableHintsObject(), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> UnreliableHintsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> UnreliableHintsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout UnreliableHintsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout UnreliableHintsGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 2/Puzzle Set 5/Unreliable hints

        Summary
        Can't trust them all

        Description
        1. Shade some tiles according to the following rules:
        2. Shaded tiles must not be orthogonally connected.
        3. You can shade tiles with arrows and numbers.
        4. All tiles which are not shaded must form an orthogonally continuous area.
        5. A cell containing a number and an arrow tells you how many tiles are shaded
           in that direction.
        6. However not all tiles that are shaded tell you lies.
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
            let os = UnreliableHintsGame.offset[hint.dir]
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
                let s: AllowedObjectState = (!UnreliableHintsGame.offset.contains {
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
            for os in UnreliableHintsGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
