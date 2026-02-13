//
//  MixedTatamisGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MixedTatamisGameState: GridGameState<MixedTatamisGameMove> {
    var game: MixedTatamisGame {
        get { getGame() as! MixedTatamisGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MixedTatamisDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> MixedTatamisGameState {
        let v = MixedTatamisGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MixedTatamisGameState) -> MixedTatamisGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MixedTatamisGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout MixedTatamisGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + MixedTatamisGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout MixedTatamisGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[move.p][move.dir]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .line
        case .line: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .line : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 4/Mixed Tatamis

        Summary
        Just that long

        Description
        1. Divide the board into areas (Tatami).
        2. Every Tatami must be exactly one cell wide and can be of length
           from 1 to 4 cells.
        3. A cell with a number indicates the length of the Tatami. Not all
           Tatamis have to be marked by a number.
        4. Two Tatamis of the same size must not be orthogonally adjacent.
        5. A grid dot must not be shared by the corners of four Tatamis
           (lines can't form 4-way crosses).
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
                    guard self[p + MixedTatamisGame.offset2[i]][MixedTatamisGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + MixedTatamisGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { p in game.pos2hint[p] != nil }
            // 3. A cell with a number indicates the length of the Tatami.
            if rng.count > 1 {
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
            var s: HintState = w == 1 && h <= 4 && h == n1 ? .complete : .error
            if s != .complete { isSolved = false }
            // 3. Not all Tatamis have to be marked by a number.
            guard !rng.isEmpty else {continue}
            let p2 = rng[0]
            let n2 = game.pos2hint[p2]!
            // 1. Just like Box It Up, you have to divide the Board in Boxes (Rectangles).
            // 3. A cell with a number indicates the length of the Tatami.
            s = s == .complete && n1 == n2 ? .complete : .error
            pos2state[p2] = s
            if s != .complete { isSolved = false }
        }
    }
}
