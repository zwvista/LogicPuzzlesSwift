//
//  LakesAndMeadowsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LakesAndMeadowsGameState: GridGameState<LakesAndMeadowsGameMove> {
    var game: LakesAndMeadowsGame {
        get { getGame() as! LakesAndMeadowsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LakesAndMeadowsDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> LakesAndMeadowsGameState {
        let v = LakesAndMeadowsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LakesAndMeadowsGameState) -> LakesAndMeadowsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: LakesAndMeadowsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.dots.objArray
        for p in game.lakes {
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
    
    override func setObject(move: inout LakesAndMeadowsGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + LakesAndMeadowsGame.offset[dir]
        guard isValid(p: p2) && game.dots[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout LakesAndMeadowsGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 2/Puzzle Set 5/Lakes and Meadows

        Summary
        Lakes and Meadows

        Description
        1. Some of the cells have lakes in them.
        2. The aim is to divide the grid into square blocks such that each
           block contains exactly one lake.
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
        for (p, node) in pos2node {
            for i in 0..<4 {
                guard self[p + LakesAndMeadowsGame.offset2[i]][LakesAndMeadowsGame.dirs[i]] != .line, let node2 = pos2node[p + LakesAndMeadowsGame.offset[i]] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { p in game.lakes.contains(p) }
            // 1. Some of the cells have lakes in them.
            // 2. The aim is to divide the grid into square blocks such that each
            //    block contains exactly one lake.
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let p2 = rng[0]
            let n1 = area.count
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
            let s: HintState = rs * cs == n1 && !hasLine() ? .complete : .error
            pos2state[p2] = s
            if s != .complete { isSolved = false }
        }
    }
}
