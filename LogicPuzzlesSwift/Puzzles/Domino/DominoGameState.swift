//
//  DominoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DominoGameState: GridGameState, DominoMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: DominoGame {
        get {return getGame() as! DominoGame}
        set {setGame(game: newValue)}
    }
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
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
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
        guard isValid(p: p2) && game[p][dir] != .line else {return false}
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed {updateIsSolved()}
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
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
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
            let node = pos2node.first!.value
            let nodesExplored = breadthFirstSearch(g, source: node)
            let area = pos2node.filter({(p, _) in nodesExplored.contains(p.description)}).map{$0.0}
            guard area.count == 2 else {isSolved = false; return}
            let domino = [game.pos2hint[area[0]]!, game.pos2hint[area[1]]!].sorted()
            // http://stackoverflow.com/questions/29736244/how-do-i-check-if-an-array-of-tuples-contains-a-particular-one-in-swift
            guard !dominoes.contains(where: {$0 == domino}) else {isSolved = false; return}
            dominoes.append(domino)
            pos2node = pos2node.filter({(p, _) in !nodesExplored.contains(p.description)})
        }
    }
}
