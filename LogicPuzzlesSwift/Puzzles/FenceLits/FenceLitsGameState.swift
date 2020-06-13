//
//  FenceLitsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FenceLitsGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: FenceLitsGame {
        get { getGame() as! FenceLitsGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: FenceLitsDocument { FenceLitsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { FenceLitsDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> FenceLitsGameState {
        let v = FenceLitsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FenceLitsGameState) -> FenceLitsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: FenceLitsGame, isCopy: Bool = false) {
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
    
    func setObject(move: inout FenceLitsGameMove) -> Bool {
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
        let p = move.p, p2 = p + FenceLitsGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return false }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed
    }
    
    func switchObject(move: inout FenceLitsGameMove) -> Bool {
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
        iOS Game: Logic Games/Puzzle Set 12/FenceLits

        Summary
        Fencing Tetris

        Description
        1. The goal is to divide the board into Tetris pieces, including the
           square one (differently from LITS).
        2. The number in a cell tells you how many of the sides are marked
           (like slitherlink).
        3. Please consider that the outside border of the board as marked.
    */
    private func updateIsSolved() {
        isSolved = true
        // 2. The number in a cell tells you how many of the sides are marked
        // (like slitherlink).
        for (p, n2) in game.pos2hint {
            var n1 = 0
            for i in 0..<4 {
                if self[p + FenceLitsGame.offset2[i]][FenceLitsGame.dirs[i]] == .line { n1 += 1 }
            }
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
        }
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
                    guard self[p + FenceLitsGame.offset2[i]][FenceLitsGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + FenceLitsGame.offset[i]]!)
                }
            }
        }
        guard isSolved else {return}
        // 1. The goal is to divide the board into Tetris pieces, including the
        // square one (differently from LITS).
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }.sorted()
            guard area.count == 4 else { isSolved = false; return }
            var areaOffsets = [Position]()
            let p2 = Position(area.min(by: { $0.row < $1.row })!.row, area.min(by: { $0.col < $1.col })!.col)
            for p in area {
                areaOffsets.append(p - p2)
            }
            guard FenceLitsGame.tetrominoes.contains(where: { $0 == areaOffsets }) else { isSolved = false; return }
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
        }
    }
}
