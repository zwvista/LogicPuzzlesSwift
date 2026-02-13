//
//  TheCityRisesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TheCityRisesGameState: GridGameState<TheCityRisesGameMove> {
    var game: TheCityRisesGame {
        get { getGame() as! TheCityRisesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TheCityRisesDocument.sharedInstance }
    var objArray = [TheCityRisesObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> TheCityRisesGameState {
        let v = TheCityRisesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TheCityRisesGameState) -> TheCityRisesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TheCityRisesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TheCityRisesObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> TheCityRisesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TheCityRisesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TheCityRisesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TheCityRisesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .block()
        case .block: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .block() : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/The City Rises

        Summary
        City Planner Revenge

        Description
        1. The board represents a piece of land where a new town should be built.
        2. Each area describes a section of land, where the town concil has decided
           to place as many city blocks as the number in it.
        3. Town blocks inside an area are horizontally or vertically contiguous.
        4. Blocks in different areas cannot touch horizontally or vertically.
        5. Areas without number can have any number of blocks, but there can't be
           empty areas.
        6. Lastly, two neighbouring areas can't have the same number of blocks in them.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2state[p] = .normal
                if case .forbidden = self[p] {
                    self[p] = .empty
                }
            }
        }
        // 3. Town blocks inside an area are horizontally or vertically contiguous.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].toString() == "block" else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in TheCityRisesGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let blocks = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            // 4. Blocks in different areas cannot touch horizontally or vertically.
            let cnt = Set(blocks.map { game.pos2area[$0]! }).count
            let s: AllowedObjectState = cnt == 1 ? .normal : .error
            if s == .error {
                isSolved = false
                for p in blocks { self[p] = .block(state: s) }
            }
            guard s == .normal else {continue}
            // 2. Each area describes a section of land, where the town concil has decided
            //    to place as many city blocks as the number in it.
            let nArea = game.pos2area[blocks[0]]!
            let area = game.areas[nArea]
            let n1 = blocks.count
            // 5. Areas without number can have any number of blocks.
            guard let pHint = game.area2hint[nArea] else {continue}
            let n2 = game.pos2hint[pHint]!
            let s2: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s2 != .complete { isSolved = false }
            pos2state[pHint] = s2
            guard allowedObjectsOnly && s2 != .normal else {continue}
            area.filter { self[$0].toString() == "empty" }.forEach {
                self[$0] = .forbidden
            }
        }
        guard isSolved else {return}
        let area2blocks = game.areas.map { $0.filter { self[$0].toString() == "block" }.count }
        // 5. There can't be empty areas.
        if area2blocks.contains(where: { $0 == 0 }) { isSolved = false }
        // 6. Lastly, two neighbouring areas can't have the same number of blocks in them.
        for (i, n) in area2blocks.enumerated() {
            guard n > 0 else {continue}
            let areas = game.area2areas[i].filter { area2blocks[$0] == n }
            guard !areas.isEmpty else {continue}
            isSolved = false
            for nArea in [i] + areas {
                guard let pHint = game.area2hint[nArea] else {continue}
                pos2state[pHint] = .error
            }
        }
   }
}
