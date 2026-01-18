//
//  UnseenGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class UnseenGameState: GridGameState<UnseenGameMove> {
    var game: UnseenGame {
        get { getGame() as! UnseenGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { UnseenDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> UnseenGameState {
        let v = UnseenGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: UnseenGameState) -> UnseenGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: UnseenGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout UnseenGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + UnseenGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout UnseenGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 3/Puzzle Set 4/Unseen

        Summary
        Round the corner

        Description
        1. Divide the board to include one 'eye' (a number) in each region.
        2. The eye can see in all four directions up to region borders.
        3. The number tells you how many tiles the eye does NOT see in the region.
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
                    guard self[p + UnseenGame.offset2[i]][UnseenGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + UnseenGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { p in game.pos2hint[p] != nil }
            // 1. Divide the board in rectangular areas, each with a number in it.
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let p = rng[0]
            let n2 = game.pos2hint[p]!
            var n1 = 0
            for i in 0..<4 {
                if self[p + UnseenGame.offset2[i]][UnseenGame.dirs[i]] == .line { n1 += 1 }
            }
            // 2. The number tells you how many sides on that tile are marked by a
            //    border, including the board external border.
            let s: HintState = n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
        }
    }
}
