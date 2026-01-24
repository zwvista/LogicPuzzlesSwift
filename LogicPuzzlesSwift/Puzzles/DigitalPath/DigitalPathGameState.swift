//
//  DigitalPathGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DigitalPathGameState: GridGameState<DigitalPathGameMove> {
    var game: DigitalPathGame {
        get { getGame() as! DigitalPathGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { DigitalPathDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> DigitalPathGameState {
        let v = DigitalPathGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: DigitalPathGameState) -> DigitalPathGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: DigitalPathGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout DigitalPathGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == DigitalPathGame.PUZ_EMPTY && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout DigitalPathGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == DigitalPathGame.PUZ_EMPTY else { return .invalid }
        let o = self[p]
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        let nMax = rows
        move.obj =
            o == DigitalPathGame.PUZ_EMPTY ? markerOption == .markerFirst ? DigitalPathGame.PUZ_MARKER : 1 :
            o == DigitalPathGame.PUZ_MARKER ? markerOption == .markerFirst ? 1 : DigitalPathGame.PUZ_EMPTY :
            o == nMax ? markerOption == .markerLast ? DigitalPathGame.PUZ_MARKER : DigitalPathGame.PUZ_EMPTY :
            o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 2/Digital Path

        Summary
        Nurikabe for robots

        Description
        1. Fill some tiles with numbers. The numbers form a Nurikabe, that is
           a path interconnected horizontally or vertically and which can' t
           cover a 2x2 area.
        2. All numbers in an area must be the same and all of them must be
           equal to the number of those numbers in the area.
        3. All regions must have at least one number.
        4. Two orthogonally adjacent tiles across areas must be different.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2state[p] = .normal
                guard self[p] == DigitalPathGame.PUZ_FORBIDDEN else {continue}
                self[p] = DigitalPathGame.PUZ_EMPTY
            }
        }
        for area in game.areas {
            var num2range = [Int: [Position]]()
            for p in area {
                let n = self[p]
                guard n > 0 else {continue}
                num2range[n, default: []].append(p)
                // 4. Two orthogonally adjacent tiles across areas must be different.
                for os in DigitalPathGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2) else {continue}
                    let n2 = self[p2]
                    if game.pos2area[p] != game.pos2area[p2] && n == n2 {
                        isSolved = false
                        pos2state[p] = .error
                        pos2state[p2] = .error
                    }
                }
            }
            // 2. All numbers in an area must be the same and all of them must be
            //    equal to the number of those numbers in the area.
            // 3. All regions must have at least one number.
            if num2range.count != 1 || num2range.keys.first != num2range.values.first!.count {
                isSolved = false
                for (_, range) in num2range {
                    for p in range { pos2state[p] = .error }
                }
            }
        }
        // 1. The numbers can' t cover a 2x2 area.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if DigitalPathGame.offset3.testAll({ self[p + $0] > 0 }) {
                    isSolved = false
                    for os in DigitalPathGame.offset3 {
                        pos2state[p + os] = .error
                    }
                }
            }
        }
        guard isSolved else {return}
        // 1. Fill some tiles with numbers. The numbers form a Nurikabe, that is
        //    a path interconnected horizontally or vertically.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p]
                guard n > 0 else {continue}
                let node = g.addNode(p.description)
                pos2node[p] = node
            }
        }
        for (p, node) in pos2node {
            for i in 0..<4 {
                let p2 = p + DigitalPathGame.offset[i]
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
