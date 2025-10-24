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
    var planks = [[Position]]()
    
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
//        // 2. Each number in a tile tells you on how many of its four sides are touched
//        // by the path.
//        for (p, n2) in game.pos2hint {
//            var n1 = 0
//            for i in 0..<4 {
//                if self[p + PlanksGame.offset2[i]][PlanksGame.dirs[i]] == .line { n1 += 1 }
//            }
//            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
//            if n1 != n2 { isSolved = false }
//        }
//        guard isSolved else {return}
//        let g = Graph()
//        var pos2node = [Position: Node]()
//        for r in 0..<rows {
//            for c in 0..<cols {
//                let p = Position(r, c)
//                let n = self[p].filter { $0 == .line }.count
//                switch n {
//                case 0:
//                    continue
//                case 2:
//                    pos2node[p] = g.addNode(p.description)
//                default:
//                    // 1. The path cannot have branches or cross itself.
//                    isSolved = false
//                    return
//                }
//            }
//        }
//        for p in pos2node.keys {
//            let dotObj = self[p]
//            for i in 0..<4 {
//                guard dotObj[i] == .line else {continue}
//                let p2 = p + PlanksGame.offset[i]
//                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
//            }
//        }
//        // 1. Draw a single looping path with the aid of the numbered hints.
//        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
//        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
