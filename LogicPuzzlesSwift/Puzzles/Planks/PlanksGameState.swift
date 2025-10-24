//
//  PlanksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PlanksGameState: GridGameState<PlanksGameMove> {
    var game: PlanksGame {
        get { getGame() as! PlanksGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PlanksDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2orient = [Position: Bool]()
    
    override func copy() -> PlanksGameState {
        let v = PlanksGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PlanksGameState) -> PlanksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PlanksGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> GridDotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    private func isValidMove(move: inout PlanksGameMove) -> Bool {
        !(move.p.row == rows - 1 && move.dir == 2 ||
            move.p.col == cols - 1 && move.dir == 1)
    }
    
    override func setObject(move: inout PlanksGameMove) -> GameOperationType {
        guard isValidMove(move: &move) else { return .invalid }
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let p = move.p
        let dir = move.dir, dir2 = (dir + 2) % 4
        f(o1: &self[p][dir], o2: &self[p + PlanksGame.offset[dir]][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout PlanksGameMove) -> GameOperationType {
        guard isValidMove(move: &move) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            default:
                return o
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 16/Planks

        Summary
        Planks and Nails

        Description
        1. On the board there are a few nails. Each one nails a plank to
           the board.
        2. Planks are 3 tiles long and can be oriented vertically or
           horizontally. The Nail can be in any of the 3 tiles.
        3. Each Plank touches orthogonally exactly two other Planks.
        4. All the Planks form a ring, or a closed loop.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
            }
        }
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for i in 0..<4 {
                    guard self[p + PlanksGame.offset2[i]][PlanksGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + PlanksGame.offset[i]]!)
                }
            }
        }
        pos2orient.removeAll()
        var planks = [[Position]]()
        var pos2plank = [Position: Int]()
        let g2 = Graph()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            var area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { game.nails.contains($0) }
            if rng.isEmpty {continue}
            // 2. Planks are 3 tiles long.
            guard area.count == 3 else { isSolved = false; continue }
            area.sort(by: <)
            let (os1, os2) = (area[1] - area[0], area[2] - area[1])
            // 2. Planks can be oriented vertically or horizontally.
            guard os1 == os2 && (os1 == PlanksGame.offset[1] || os1 == PlanksGame.offset[2]) else { isSolved = false; continue }
            // 1. On the board there are a few nails. Each one nails a plank to
            //    the board.
            // 2. The Nail can be in any of the 3 tiles.
            guard rng.count == 1 else { isSolved = false; continue }
            let n = planks.count
            planks.append(area)
            for p in area {
                pos2plank[p] = n
                pos2orient[p] = os1 == PlanksGame.offset[1]
            }
            _ = g2.addNode(String(n))
        }
        for (i, plank) in planks.enumerated() {
            var neighbors = Set<Int>()
            for p in plank {
                for os in PlanksGame.offset {
                    guard let n = pos2plank[p + os], n != i else {continue}
                    neighbors.insert(n)
                }
            }
            // 3. Each Plank touches orthogonally exactly two other Planks.
            guard neighbors.count == 2 else { isSolved = false; return }
            for n in neighbors { g2.addEdge(g2.nodes[i], neighbor: g2.nodes[n]) }
        }
        guard isSolved else { return }
        // 4. All the Planks form a ring, or a closed loop.
        let nodesExplored = breadthFirstSearch(g2, source: g2.nodes[0])
        if nodesExplored.count != g2.nodes.count { isSolved = false }
    }
}
