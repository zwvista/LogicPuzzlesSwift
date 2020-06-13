//
//  FillominoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FillominoGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: FillominoGame {
        get { getGame() as! FillominoGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: FillominoDocument { FillominoDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { FillominoDocument.sharedInstance }
    var objArray = [Character]()
    var dots: GridDots!
    var pos2state = [Position: HintState]()
    
    override func copy() -> FillominoGameState {
        let v = FillominoGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FillominoGameState) -> FillominoGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: FillominoGame, isCopy: Bool = false) {
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
    
    func setObject(move: inout FillominoGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout FillominoGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return false }
        let o = self[p]
        move.obj =
            o == " " ? "1" :
            o == game.chMax ? " " :
            succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 3/Fillomino

        Summary
        Detect areas marked by their extension

        Description
        1. The goal is to detect areas marked with the tile count of the area
           itself.
        2. So for example, areas marked '1', will always consist of one single
           tile. Areas marked with '2' will consist of two (horizontally or
           vertically) adjacent tiles. Tiles numbered '3' will appear in a group
           of three and so on.
        3. Two areas with the same areas can also be totally hidden at the start.
     
        Variation
        4. Fillomino has several variants.
        5. No Rectangles: Areas can't form Rectangles.
        6. Only Rectangles: Areas can ONLY form Rectangles.
        7. Non Consecutive: Areas can't touch another area which has +1 or -1
           as number (orthogonally).
        8. Consecutive: Areas MUST touch another area which has +1 or -1
           as number (orthogonally).
        9. All Odds: There are only odd numbers on the board.
        10.All Evens: There are only even numbers on the board.
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
                for os in FillominoGame.offset {
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
                    let p2 = p + FillominoGame.offset[i]
                    let ch2 = !isValid(p: p2) ? "." : self[p2]
                    if ch2 != ch && (n1 <= n2 || ch2 != " ") {
                        dots[p + FillominoGame.offset2[i]][FillominoGame.dirs[i]] = .line
                    }
                }
            }
            if s != .complete { isSolved = false }
        }
    }
}
