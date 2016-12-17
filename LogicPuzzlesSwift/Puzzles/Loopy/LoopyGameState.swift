//
//  LoopyGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LoopyGameState: CellsGameState, LoopyMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: LoopyGame {
        get {return getGame() as! LoopyGame}
        set {setGame(game: newValue)}
    }
    var objArray = [LoopyObject]()
    
    override func copy() -> LoopyGameState {
        let v = LoopyGameState(game: game)
        return setup(v: v)
    }
    func setup(v: LoopyGameState) -> LoopyGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LoopyGame) {
        super.init(game: game);
        objArray = Array<LoopyObject>(repeating: Array<Bool>(repeating: false, count: 4), count: rows * cols)
        for r in 0..<rows {
            for c in 0..<cols {
                for dir in 1...2 {
                    guard game[r, c][dir] else {continue}
                    var move = LoopyGameMove(p: Position(r, c), dir: dir)
                    _ = setObject(move: &move)
                }
            }
        }
    }
    
    subscript(p: Position) -> LoopyObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> LoopyObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout LoopyGameMove) -> Bool {
        let p = move.p, dir = move.dir
        let p2 = p + LoopyGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && !(game[p][dir] && self[p][dir]) else {return false}
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return true
    }
    
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].filter({$0}).count
                switch n {
                case 2:
                    pos2node[p] = g.addNode(label: p.description)
                default:
                    isSolved = false
                    return
                }
            }
        }
        for p in pos2node.keys {
            let dotObj = self[p]
            for i in 0..<4 {
                guard dotObj[i] else {continue}
                let p2 = p + LoopyGame.offset[i]
                g.addEdge(source: pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
        let n1 = nodesExplored.count
        let n2 = pos2node.values.count
        if n1 != n2 {isSolved = false}
    }
}
