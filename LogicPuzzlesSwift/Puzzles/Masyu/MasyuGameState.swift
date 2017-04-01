//
//  MasyuGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MasyuGameState: GridGameState, MasyuMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: MasyuGame {
        get {return getGame() as! MasyuGame}
        set {setGame(game: newValue)}
    }
    var objArray = [MasyuObject]()
    
    override func copy() -> MasyuGameState {
        let v = MasyuGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MasyuGameState) -> MasyuGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MasyuGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MasyuObject>(repeating: MasyuObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MasyuObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> MasyuObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout MasyuGameMove) -> Bool {
        let p = move.p, dir = move.dir
        let p2 = p + MasyuGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else {return false}
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return true
    }
    
    
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        var pos2Dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let ch = game[p]
                var dirs = [Int]()
                for i in 0..<4 {
                    if o[i] {dirs.append(i)}
                }
                switch dirs.count {
                case 0:
                    guard ch == " " else {isSolved = false; return}
                case 2:
                    pos2node[p] = g.addNode(p.description)
                    pos2Dirs[p] = dirs
                    switch ch {
                    case "B":
                        guard dirs[1] - dirs[0] != 2 else {isSolved = false; return}
                    case "W":
                        guard dirs[1] - dirs[0] == 2 else {isSolved = false; return}
                    default:
                        break
                    }
                default:
                    isSolved = false; return
                }
            }
        }
        for (p, node) in pos2node {
            let dirs = pos2Dirs[p]!
            let ch = game[p]
            var bW = ch != "W"
            for i in dirs {
                let p2 = p + MasyuGame.offset[i]
                guard let node2 = pos2node[p2], let dirs2 = pos2Dirs[p2] else {isSolved = false; return}
                switch ch {
                case "B":
                    guard (i == 0 || i == 2) && dirs2[0] == 0 && dirs2[1] == 2 || (i == 1 || i == 3) && dirs2[0] == 1 && dirs2[1] == 3 else {isSolved = false; return}
                case "W":
                    let n1 = (i + 1) % 4, n2 = (i + 3) % 4
                    if dirs2[0] == n1 || dirs2[0] == n2 || dirs2[1] == n1 || dirs2[1] == n2 {bW = true}
                default:
                    break
                }
                g.addEdge(node, neighbor: node2)
            }
            guard bW else {isSolved = false; return}
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
        let n1 = nodesExplored.count
        let n2 = pos2node.values.count
        if n1 != n2 {isSolved = false}
    }
}
