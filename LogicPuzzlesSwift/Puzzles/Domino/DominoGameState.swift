//
//  DominoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DominoGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: DominoGame {
        get { getGame() as! DominoGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: DominoDocument { DominoDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { DominoDocument.sharedInstance }
    var objArray = [GridDotObject]()
    
    override func copy() -> DominoGameState {
        let v = DominoGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: DominoGameState) -> DominoGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: DominoGame, isCopy: Bool = false) {
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
    
    func setObject(move: inout DominoGameMove) -> Bool {
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
        let p = move.p, p2 = p + DominoGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return false }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed
    }
    
    func switchObject(move: inout DominoGameMove) -> Bool {
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
        iOS Game: Logic Games/Puzzle Set 5/Domino

        Summary
        Find all the Domino tiles

        Description
        1. On the board there is a complete Domino set. The Domino tiles borders
           however aren't marked, it's up to you to identify them.
        2. In early levels the board contains a smaller Domino set, of numbers
           ranging from 0 to 3.
        3. This means you will be looking for a Domino set composed of these
           combinations.
           0-0, 0-1, 0-2, 0-3
           1-1, 1-2, 1-3
           2-2, 2-3
           3-3
        4. In harder levels, the Domino set will also include fours, fives,
           sixes, etc.
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
                    guard self[p + DominoGame.offset2[i]][DominoGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + DominoGame.offset[i]]!)
                }
            }
        }
        var dominoes = [[Int]]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }
            guard area.count == 2 else { isSolved = false; return }
            let domino = [game.pos2hint[area[0]]!, game.pos2hint[area[1]]!].sorted()
            // 2. In early levels the board contains a smaller Domino set, of numbers ranging from 0 to 3.
            // 3. This means you will be looking for a Domino set composed of these combinations.
            guard !dominoes.contains(where: { $0 == domino }) else { isSolved = false; return }
            dominoes.append(domino)
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
        }
    }
}
