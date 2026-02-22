//
//  MondrianLoopGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MondrianLoopGameState: GridGameState<MondrianLoopGameMove> {
    var game: MondrianLoopGame {
        get { getGame() as! MondrianLoopGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MondrianLoopDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var rectangles = [[Position]]()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    
    override func copy() -> MondrianLoopGameState {
        let v = MondrianLoopGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MondrianLoopGameState) -> MondrianLoopGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MondrianLoopGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout MondrianLoopGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + MondrianLoopGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout MondrianLoopGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 4/Puzzle Set 2/Mondrian Loop

        Summary
        Lots of artists around here

        Description
        1. Enough with impressionists, time for a nice geometric painting
           called Squarism!
        2. Divide the board in many rectangles or squares. Each
           rectangle/square can contain only one number, which represents
           its area, but it can also contain none.
        3. The rectangles/squares can't touch each other with their sides
           (they can't share a side), but they have to form a loop by
           connecting with their corners.
        4. In the end there must be a single loop that connects all
           rectangles/squares by corners.
    */
    private func updateIsSolved() {
        isSolved = true
        for p in game.pos2hint.keys {
            pos2stateHint[p] = .normal
        }
        var emptyRects = [[Position]]()
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
                    guard self[p + MondrianLoopGame.offset2[i]][MondrianLoopGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + MondrianLoopGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            // 2. Divide the board in many rectangles or squares.
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
            let isRect = rs * cs == area.count && !hasLine()
            guard isRect else { isSolved = false; continue }
            // 2. Each rectangle/square can contain only one number, which represents
            //    its area, but it can also contain none.
            let rng = area.filter { p in game.pos2hint[p] != nil }
            guard rng.count < 2 else { isSolved = false; continue }
            if rng.isEmpty {
                emptyRects.append(area)
            } else {
                rectangles.append(area)
                let pHint = rng[0]
                let n1 = area.count, n2 = game.pos2hint[pHint]!
                let s: HintState = n2 == MondrianLoopGame.PUZ_UNKNOWN || n1 == n2 ? .complete : .error
                pos2stateHint[pHint] = s
                if s != .complete { isSolved = false }
            }
        }
        guard isSolved else {return}
        // 3. The rectangles/squares can't touch each other with their sides
        //    (they can't share a side)
        emptyRects = emptyRects.filter { rect in
            rect.allSatisfy { p in
                MondrianLoopGame.offset.allSatisfy {
                    let p2 = p + $0
                    return rect.contains(p2) || !rectangles.contains { $0.contains(p2) }
                }
            }
        }
        rectangles.append(contentsOf: emptyRects)
        guard (rectangles.allSatisfy { rect in
            rect.allSatisfy { p in
                MondrianLoopGame.offset.allSatisfy {
                    let p2 = p + $0
                    return rect.contains(p2) || !rectangles.contains { $0.contains(p2) }
                }
            }
        }) else { isSolved = false; return }
        // 4. In the end there must be a single loop that connects all
        //    rectangles/squares by corners.
        var id2ids = [Int: [Int]]()
        for (i, rect) in rectangles.enumerated() {
            id2ids[i] = Array(Set(rect.flatMap { p in
                MondrianLoopGame.offset3
                    .map { p + $0 }
                    .filter { isValid(p: $0) }
                    .compactMap { p2 in
                        rectangles.indices.first { j in j != i && rectangles[j].contains(p2) }
                    }
            }))
        }
        guard (id2ids.allSatisfy { (id, ids) in
            ids.count == 2
        }) else { isSolved = false; return }
        // Check the loop
        let id = id2ids.keys.first!
        var id2 = id, n = -1
        while true {
            guard let ids = id2ids[id2] else { isSolved = false; return }
            id2ids.removeValue(forKey: id2)
            for id3 in ids {
                if id3 != n {
                    n = id2
                    id2 = id3
                    break
                }
            }
            guard id2 != id else {break}
        }
    }
}
