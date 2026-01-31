//
//  NewCarpenterSquareGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NewCarpenterSquareGameState: GridGameState<NewCarpenterSquareGameMove> {
    var game: NewCarpenterSquareGame {
        get { getGame() as! NewCarpenterSquareGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { NewCarpenterSquareDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> NewCarpenterSquareGameState {
        let v = NewCarpenterSquareGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NewCarpenterSquareGameState) -> NewCarpenterSquareGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: NewCarpenterSquareGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout NewCarpenterSquareGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + NewCarpenterSquareGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout NewCarpenterSquareGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 3/Puzzle Set 3/New Carpenter Square

        Summary
        The old one was cooked

        Description
        1. Divide the board in 'L'-shaped figures, with one cell wide 'legs'.
        2. Every symbol on the board represents the corner of an L.
           there are no hidden L's.
        3. A = symbol tells you that the legs have equal length.
        4. A ÅÇ symbol tells you that the legs have different lengths.
        5. A ? symbol tells you that the legs could have different lengths
           or equal length.
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
                    guard self[p + NewCarpenterSquareGame.offset2[i]][NewCarpenterSquareGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + NewCarpenterSquareGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rngHint = area.filter { game.pos2hint[$0] != nil }
            // 2. Every symbol on the board represents the corner of an L.
            //    there are no hidden L's.
            if rngHint.count != 1 {
                isSolved = false
                for p in rngHint { pos2state[p] = .normal }
                continue
            }
            let pHint = rngHint.first!
            let n1 = nodesExplored.count
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in area {
                if r2 < p.row { r2 = p.row }
                if r1 > p.row { r1 = p.row }
                if c2 < p.col { c2 = p.col }
                if c1 > p.col { c1 = p.col }
            }
            if r1 == r2 || c1 == c2 { isSolved = false; continue }
            let cntR1 = area.filter { $0.row == r1 }.count
            let cntR2 = area.filter { $0.row == r2 }.count
            let cntC1 = area.filter { $0.col == c1 }.count
            let cntC2 = area.filter { $0.col == c2 }.count
            func f(_ a: Int, _ b: Int) -> Bool { a > 1 && b > 1 && a + b - 1 == n1 }
            // 1. Divide the board in 'L'-shaped figures, with one cell wide 'legs'.
            let squareType =
                f(cntR1, cntC1) ? 0 : // ┌
                f(cntR1, cntC2) ? 1 : // ┐
                f(cntR2, cntC1) ? 2 : // └
                f(cntR2, cntC2) ? 3 : -1 // ┘
            let equalArms =
                squareType == 0 && cntR1 == cntC1 ||
                squareType == 1 && cntR1 == cntC2 ||
                squareType == 2 && cntR2 == cntC1 ||
                squareType == 3 && cntR2 == cntC2
            if squareType == -1 { isSolved = false }
            let h = game.pos2hint[pHint]!
            // 3. A = symbol tells you that the legs have equal length.
            // 4. A ÅÇ symbol tells you that the legs have different lengths.
            // 5. A ? symbol tells you that the legs could have different lengths
            //    or equal length.
            let s: HintState = squareType == -1 ? .normal : !(h == .unknown || (h == .equal) == equalArms) ? .error : squareType == 0 && pHint == Position(r1, c1) || squareType == 1 && pHint == Position(r1, c2) || squareType == 2 && pHint == Position(r2, c1) || squareType == 3 && pHint == Position(r2, c2) ? .complete : .error
            pos2state[pHint] = s
            if s != .complete { isSolved = false }
        }
    }
}
