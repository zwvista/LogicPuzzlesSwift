//
//  TataminoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TataminoGameState: GridGameState<TataminoGame, TataminoGameMove> {
    override var gameDocument: GameDocumentBase { TataminoDocument.sharedInstance }
    var objArray = [Character]()
    var dots: GridDots!
    var pos2state = [Position: HintState]()
    
    override func copy() -> TataminoGameState {
        let v = TataminoGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TataminoGameState) -> TataminoGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: TataminoGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TataminoGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout TataminoGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return false }
        let o = self[p]
        move.obj =
            o == " " ? "1" :
            o == "3" ? " " :
            succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 13/Tatamino

        Summary
        Which is a little Tatami

        Description
        1. Plays like Fillomino, in which you have to guess areas on the board
           marked by their number.
        2. In Tatamino, however, you only have areas 1, 2 and 3 tiles big.
        3. Please remember two areas of the same number size can't be touching.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == " " {
                    isSolved = false
                } else {
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = self[p]
                guard ch != " " else {continue}
                for os in TataminoGame.offset {
                    let p2 = p + os
                    if isValid(p: p2) && self[p2] == ch {
                        g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                    }
                }
            }
        }
        dots = GridDots(x: game.dots)
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
            let ch = self[area[0]]
            let (n1, n2) = (area.count, ch.toInt!)
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            for p in area {
                pos2state[p] = s
                for i in 0..<4 {
                    let p2 = p + TataminoGame.offset[i]
                    let ch2 = !isValid(p: p2) ? "." : self[p2]
                    if ch2 != ch && (n1 <= n2 || ch2 != " ") {
                        dots[p + TataminoGame.offset2[i]][TataminoGame.dirs[i]] = .line
                    }
                }
            }
            if s != .complete { isSolved = false }
        }
    }
}
