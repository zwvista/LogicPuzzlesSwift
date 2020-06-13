//
//  NorthPoleFishingGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NorthPoleFishingGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: NorthPoleFishingGame {
        get { getGame() as! NorthPoleFishingGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: NorthPoleFishingDocument { NorthPoleFishingDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { NorthPoleFishingDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> NorthPoleFishingGameState {
        let v = NorthPoleFishingGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NorthPoleFishingGameState) -> NorthPoleFishingGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: NorthPoleFishingGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.dots.objArray
        for p in game.holes {
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
    
    func setObject(move: inout NorthPoleFishingGameMove) -> Bool {
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
        let p = move.p, p2 = p + NorthPoleFishingGame.offset[dir]
        guard isValid(p: p2) && game.dots[p][dir] == .empty else { return false }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed
    }
    
    func switchObject(move: inout NorthPoleFishingGameMove) -> Bool {
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
        iOS Game: Logic Games/Puzzle Set 14/North Pole Fishing

        Summary
        Fishing Neighbours

        Description
        1. The board represents a piece of antarctic, which some fisherman want
           to split in equal parts.
        2. They decide each one should have a piece of land of exactly 4 squares,
           including one fishing hole.
        3. Divide the land accordingly.
        4. Ice blocks are just obstacles and don't count as piece of land.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                guard game[p] != .block else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for i in 0..<4 {
                guard self[p + NorthPoleFishingGame.offset2[i]][NorthPoleFishingGame.dirs[i]] != .line, let node2 = pos2node[p + NorthPoleFishingGame.offset[i]] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
            let rng = area.filter { p in game.holes.contains(p) }
            // 2. They decide each one should have a piece of land of exactly 4 squares,
            // including one fishing hole.
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let p2 = rng[0]
            let n1 = area.count, n2 = 4
            let s: HintState = n1 == n2 ? .complete : .error
            pos2state[p2] = s
            if s != .complete { isSolved = false }
        }
    }
}
