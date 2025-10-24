//
//  OverUnderGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class OverUnderGameState: GridGameState<OverUnderGameMove> {
    var game: OverUnderGame {
        get { getGame() as! OverUnderGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { OverUnderDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> OverUnderGameState {
        let v = OverUnderGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: OverUnderGameState) -> OverUnderGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: OverUnderGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
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
    
    override func setObject(move: inout OverUnderGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + OverUnderGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout OverUnderGameMove) -> GameOperationType {
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
        iOS Game: Logic Games/Puzzle Set 15/Over Under

        Summary
        Over and Under regions

        Description
        1. Divide the board in regions following these rules:
        2. Each region must contain two numbers.
        3. The region size must be between the two numbers.
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
                    guard self[p + OverUnderGame.offset2[i]][OverUnderGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + OverUnderGame.offset[i]]!)
                }
            }
        }
        var areas = [[Position]]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            areas.append(area)
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
        }
        for area in areas {
            let rng = area.filter { p in game.pos2hint[p] != nil }
            // 2. Each region must contain two numbers.
            if rng.count != 2 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let n1 = area.count
            let p2 = rng[0], p3 = rng[1]
            var n2 = game.pos2hint[p2]!, n3 = game.pos2hint[p3]!
            if n2 > n3 { swap(&n2, &n3) }
            // 3. The region size must be between the two numbers.
            let s: HintState = n1 > n2 && n1 < n3 ? .complete : .error
            pos2state[p2] = s; pos2state[p3] = s
            if s != .complete { isSolved = false }
        }
    }
}
