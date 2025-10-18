//
//  WarehouseGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class WarehouseGameState: GridGameState<WarehouseGameMove> {
    var game: WarehouseGame {
        get { getGame() as! WarehouseGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { WarehouseDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: AllowedObjectState]()
    var dot2state = [Position: AllowedObjectState]()
    
    override func copy() -> WarehouseGameState {
        let v = WarehouseGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: WarehouseGameState) -> WarehouseGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: WarehouseGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        for p in game.pos2symbol.keys {
            pos2state[p] = .error
        }
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
    
    override func setObject(move: inout WarehouseGameMove) -> GameOperationType {
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
        let dir = move.dir, dir2 = (dir + 2) % 4
        let p = move.p, p2 = p + WarehouseGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete: .invalid
    }
    
    override func switchObject(move: inout WarehouseGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 2/Puzzle Set 8/Warehouse

        Summary
        Packed with crates

        Description
        1. The board represents a warehouse, packed with boxes which you must find.
        2. Each box contains a symbol:
        3. a cross means it's a square box.
        4. a horizontal bar means the box is wider than taller.
        5. a vertical bar means the box is taller than wider.
        6. A grid dot must not be shared by the corners of four boxes.
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
                    guard self[p + WarehouseGame.offset2[i]][WarehouseGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + WarehouseGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
            let rng = area.filter { p in game.pos2symbol[p] != nil }
            // 2. Each box contains a symbol:
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .error
                }
                isSolved = false; continue
            }
            let p2 = rng[0]
            let n1 = area.count, n2 = game.pos2symbol[p2]!
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in area {
                if r2 < p.row { r2 = p.row }
                if r1 > p.row { r1 = p.row }
                if c2 < p.col { c2 = p.col }
                if c1 > p.col { c1 = p.col }
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1
            func hasLine() -> Bool {
                for r in r1...r2 {
                    for c in c1...c2 {
                        let dotObj = self[r + 1, c + 1]
                        if r < r2 && dotObj[3] == .line || c < c2 && dotObj[0] == .line { return true }
                    }
                }
                return false
            }
            // 3. a cross means it's a square box.
            // 4. a horizontal bar means the box is wider than taller.
            // 5. a vertical bar means the box is taller than wider.
            let ch = game.pos2symbol[p2]!
            pos2state[p2] = (ch == WarehouseGame.PUZ_HORZ ? rs < cs : ch == WarehouseGame.PUZ_VERT ? rs > cs : rs == cs) && !hasLine() ? .normal : .error
            if pos2state[p2] != .normal { isSolved = false }
        }
        // 6. A grid dot must not be shared by the corners of four boxes.
        dot2state.removeAll()
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                let has4 = (0..<4).allSatisfy { self[p][$0] == .line }
                dot2state[p] = has4 ? .error : .normal
                if (has4) { isSolved = false }
            }
        }
    }
}
