//
//  HiddenPathGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HiddenPathGameState: GridGameState<HiddenPathGameMove> {
    var game: HiddenPathGame {
        get { getGame() as! HiddenPathGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { HiddenPathDocument.sharedInstance }
    var objArray = [HiddenPathObject]()
    
    override func copy() -> HiddenPathGameState {
        let v = HiddenPathGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: HiddenPathGameState) -> HiddenPathGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: HiddenPathGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<HiddenPathObject>(repeating: HiddenPathObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> HiddenPathObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> HiddenPathObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout HiddenPathGameMove) -> Bool {
        let p = move.p, dir = move.dir
        let p2 = p + HiddenPathGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return false }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return true
    }
    
    
    /*
        iOS Game: Logic Games/Puzzle Set 15/Number Path

        Summary
        Tangled, Scrambled Path

        Description
        1. Connect the top left corner (1) to the bottom right corner (N), including
           all the numbers between 1 and N, only once.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        let (pStart, pEnd) = (Position(0, 0), Position(rows - 1, cols - 1))
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].filter { $0 }.count
                if p == pStart || p == pEnd {
                    // 1. Connect the top left corner (1) to the bottom right corner (N).
                    if n != 1 { isSolved = false; return }
                    pos2node[p] = g.addNode(p.description); continue
                }
                switch n {
                case 0:
                    continue
                case 2:
                    pos2node[p] = g.addNode(p.description)
                default:
                    isSolved = false; return
                }
            }
        }
        var nums = Set<Int>()
        for p in pos2node.keys {
            let o = self[p]
            nums.insert(game[p])
            for i in 0..<4 {
                guard o[i] else {continue}
                let p2 = p + HiddenPathGame.offset[i]
                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        // 1. Connect the top left corner (1) to the bottom right corner (N), including
        // all the numbers between 1 and N, only once.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        let n1 = game[pEnd], n2 = nums.count, n3 = pos2node.count, n4 = nodesExplored.count
        if n1 != n2 || n1 != n3 || n1 != n4 { isSolved = false }
    }
}
