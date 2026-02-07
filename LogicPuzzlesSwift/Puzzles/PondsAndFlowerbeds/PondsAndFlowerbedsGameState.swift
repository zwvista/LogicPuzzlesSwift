//
//  PondsAndFlowerbedsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PondsAndFlowerbedsGameState: GridGameState<PondsAndFlowerbedsGameMove> {
    var game: PondsAndFlowerbedsGame {
        get { getGame() as! PondsAndFlowerbedsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PondsAndFlowerbedsDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2stateHint = [Position: HintState]()
    var shrubs = Set<Position>()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    
    override func copy() -> PondsAndFlowerbedsGameState {
        let v = PondsAndFlowerbedsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PondsAndFlowerbedsGameState) -> PondsAndFlowerbedsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PondsAndFlowerbedsGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout PondsAndFlowerbedsGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + PondsAndFlowerbedsGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout PondsAndFlowerbedsGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 2/Puzzle Set 3/Ponds and Flowerbeds

        Summary
        Mad Gardener!

        Description
        1. The aim is to locate some Flowerbeds and Ponds in the field.
        2. A Flowerbed is an area of 3 cells, containing one flower.
        3. A Pond is an area of any size without flower.
        4. Each 2x2 area must contain at least a Hedge or a Pond.
        5. Hedges when presents, are given in light green.
    */
    private func updateIsSolved() {
        isSolved = true
        var flowerbeds = [[Position]]()
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
                    guard self[p + PondsAndFlowerbedsGame.offset2[i]][PondsAndFlowerbedsGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + PondsAndFlowerbedsGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { p in game.pos2hint[p] != nil }
            // 1. Divide the board in Flowerbeds of exactly three tiles. Each Flowerbed
            //    contains a number.
            let cnt = area.count
            if rng.isEmpty {
                if cnt == 1 {
                    shrubs.insert(area[0])
                } else {
                    isSolved = false
                }
            } else if rng.count > 1 || cnt != 3 {
                for p in rng {
                    pos2stateHint[p] = .normal
                }
                isSolved = false
            } else {
                flowerbeds.append(area)
            }
        }
        // 2. Single tiles left outside Flowerbeds are Shrubs. Shrubs cannot touch
        //    each other orthogonally.
        for p in shrubs {
            let rng = PondsAndFlowerbedsGame.offset.map { p + $0 }.filter { shrubs.contains($0) }
            pos2stateAllowed[p] = rng.isEmpty ? .normal : .error
        }
        // 3. The number on each Flowerbed tells you how many Shrubs are adjacent to it.
        for area in flowerbeds {
            let pHint = area.first { game.pos2hint[$0] != nil }!
            let n1 = game.pos2hint[pHint]!
            let shrubs2 = Set(area.flatMap { p in PondsAndFlowerbedsGame.offset.map { p + $0 } }.filter { shrubs.contains($0) })
            let n2 = shrubs2.count
            let s: HintState = n1 == n2 ? .complete : .error
            pos2stateHint[pHint] = s
            if s != .complete { isSolved = false }
        }
    }
}
