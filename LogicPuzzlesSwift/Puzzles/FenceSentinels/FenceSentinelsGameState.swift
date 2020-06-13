//
//  FenceSentinelsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FenceSentinelsGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: FenceSentinelsGame {
        get { getGame() as! FenceSentinelsGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: FenceSentinelsDocument { FenceSentinelsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { FenceSentinelsDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> FenceSentinelsGameState {
        let v = FenceSentinelsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FenceSentinelsGameState) -> FenceSentinelsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: FenceSentinelsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
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
    
    private func isValidMove(move: inout FenceSentinelsGameMove) -> Bool {
        return !(move.p.row == rows - 1 && move.dir == 2 ||
                move.p.col == cols - 1 && move.dir == 1)
    }
    
    func setObject(move: inout FenceSentinelsGameMove) -> Bool {
        guard isValidMove(move: &move) else { return false }
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
        f(o1: &self[p][dir], o2: &self[p + FenceSentinelsGame.offset[dir]][dir2])
        if changed { updateIsSolved() }
        return changed
    }
    
    func switchObject(move: inout FenceSentinelsGameMove) -> Bool {
        guard isValidMove(move: &move) else { return false }
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
        iOS Game: Logic Games/Puzzle Set 12/Fence Sentinels

        Summary
        We used to guard a castle, you know?

        Description
        1. The goal is to draw a single, uninterrupted, closed loop.
        2. The loop goes around all the numbers.
        3. The number tells you how many cells you can see horizontally or
           vertically from there, including the cell itself.

        Variant
        4. Some levels are marked 'Inside Outside'. In this case some numbers
           are on the outside of the loop.
    */
    private func updateIsSolved() {
        isSolved = true
        // 2. The loop goes around all the numbers.
        // 3. The number tells you how many cells you can see horizontally or
        // vertically from there, including the cell itself.
        for (p, n2) in game.pos2hint {
            var n1 = -3
            for i in 0..<4 {
                let os = FenceSentinelsGame.offset[i]
                var p2 = p
                while game.isValid(p: p2) {
                    n1 += 1
                    guard self[p2 + FenceSentinelsGame.offset2[i]][FenceSentinelsGame.dirs[i]] != .line else {break}
                    p2 += os
                }
            }
            pos2state[p] = n1 > n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].filter { $0 == .line }.count
                switch n {
                case 0:
                    continue
                case 2:
                    pos2node[p] = g.addNode(p.description)
                default:
                    isSolved = false
                    return
                }
            }
        }
        for p in pos2node.keys {
            let dotObj = self[p]
            for i in 0..<4 {
                guard dotObj[i] == .line else {continue}
                let p2 = p + FenceSentinelsGame.offset[i]
                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        // 1. The goal is to draw a single, uninterrupted, closed loop.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
