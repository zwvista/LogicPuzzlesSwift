//
//  InsaneTatamisGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class InsaneTatamisGameState: GridGameState<InsaneTatamisGameMove> {
    var game: InsaneTatamisGame {
        get { getGame() as! InsaneTatamisGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { InsaneTatamisDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    var invalidDots = [Position]()
    
    override func copy() -> InsaneTatamisGameState {
        let v = InsaneTatamisGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: InsaneTatamisGameState) -> InsaneTatamisGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: InsaneTatamisGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout InsaneTatamisGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + InsaneTatamisGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout InsaneTatamisGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 2/Puzzle Set 5/Insane Tatamis

        Summary
        Not that long

        Description
        1. Divide the board into rectangular areas, each containing a number.
        2. Every area must be exactly one tile wide.
        3. The length of the other side is NOT equal to the number of this
           region.
        4. A grid dot must not be shared by the corners of four areas.
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
                    guard self[p + InsaneTatamisGame.offset2[i]][InsaneTatamisGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + InsaneTatamisGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { p in game.pos2hint[p] != nil }
            // 1. Divide the board into rectangular areas, each containing a number.
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let n1 = area.count
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in area {
                if r2 < p.row { r2 = p.row }
                if r1 > p.row { r1 = p.row }
                if c2 < p.col { c2 = p.col }
                if c1 > p.col { c1 = p.col }
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1
            let (w, h) = rs < cs ? (rs, cs) : (cs, rs)
            // 2. Every area must be exactly one tile wide.
            var s: HintState = w == 1 && h == n1 ? .complete : .error
            if s != .complete { isSolved = false }
            let p2 = rng[0]
            let n2 = game.pos2hint[p2]!
            // 3. The length of the other side is NOT equal to the number of this
            //    region.
            s = s == .complete && n1 != n2 ? .complete : .error
            pos2state[p2] = s
            if s != .complete { isSolved = false }
        }
        // 4. A grid dot must not be shared by the corners of four areas.
        invalidDots.removeAll()
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                guard (0..<4).allSatisfy({ self[p][$0] == .line }) else {continue}
                invalidDots.append(p)
            }
        }
    }
}
