//
//  FenceItUpGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FenceItUpGameState: GridGameState<FenceItUpGameMove> {
    var game: FenceItUpGame {
        get { getGame() as! FenceItUpGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FenceItUpDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> FenceItUpGameState {
        let v = FenceItUpGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FenceItUpGameState) -> FenceItUpGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FenceItUpGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout FenceItUpGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + FenceItUpGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout FenceItUpGameMove) -> GameOperationType {
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
        iOS Game: Logic Games/Puzzle Set 7/Fence It Up

        Summary
        Now with Fences

        Description
        1. A simple puzzle where you have to divide the Board into enclosed
           areas by Fences.
        2. Each area must contain one number and the number tells you the length
           of the perimeter of the area.
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
                    guard self[p + FenceItUpGame.offset2[i]][FenceItUpGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + FenceItUpGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { p in game.pos2hint[p] != nil }
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let p2 = rng[0]
            let n2 = game.pos2hint[p2]!
            var n1 = 0
            // 2. Each area must contain one number and the number tells you the length
            // of the perimeter of the area.
            for p in area {
                for i in 0..<4 {
                    if self[p + FenceItUpGame.offset2[i]][FenceItUpGame.dirs[i]] == .line { n1 += 1 }
                }
            }
            pos2state[p2] = n1 == n2 ? .complete : .error
            if pos2state[p2] != .complete { isSolved = false }
        }
    }
}
