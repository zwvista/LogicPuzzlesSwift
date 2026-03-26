//
//  FillominoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FillominoGameState: GridGameState<FillominoGameMove> {
    var game: FillominoGame {
        get { getGame() as! FillominoGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FillominoDocument.sharedInstance }
    var objArray = [Character]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> FillominoGameState {
        let v = FillominoGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FillominoGameState) -> FillominoGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
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
    
    override func setObject(move: inout FillominoGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FillominoGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return .invalid }
        let o = self[p]
        move.obj =
            o == " " ? "1" :
            o == game.chMax ? " " :
            succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 3/Fillomino

        Summary
        Detect areas marked by their extension

        Description
        1. The goal is to detect areas marked with the tile count of the area
           itself.
        2. So for example, areas marked '1', will always consist of one single
           tile. Areas marked with '2' will consist of two (horizontally or
           vertically) adjacent tiles. Tiles numbered '3' will appear in a group
           of three and so on.
        3. Two areas with the same number can't be horizontally or vertically touching.
        4. Lastly, please note that some areas can also be totally hidden at the start.
           In the example you can see a '1' which wasn't hinted in the initial setup.

        Variation
        5. Fillomino has several variants.
        6. No Rectangles: Areas can't form Rectangles.
        7. Only Rectangles: Areas can ONLY form Rectangles.
        8. Non Consecutive: Areas can't touch another area which has +1 or -1
           as number (orthogonally).
        9. Consecutive: Areas MUST touch another area which has +1 or -1
           as number (orthogonally).
        10.No Row or Column Repeats: Different areas with the same number
           can't appear in the same column or row.
        11.All Odds: There are only odd numbers on the board.
        12.All Evens: There are only even numbers on the board.
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
        for (p, node) in pos2node {
            let ch = self[p]
            for os in FillominoGame.offset {
                let p2 = p + os
                guard isValid(p: p2) && self[p2] == ch else {continue}
                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let ch = self[area[0]]
            let (n1, n2) = (area.count, ch.toInt!)
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            for p in area { pos2state[p] = s }
            if s != .complete { isSolved = false }
        }
    }
}
