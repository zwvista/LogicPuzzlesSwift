//
//  PlugItInGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PlugItInGameState: GridGameState<PlugItInGameMove> {
    var game: PlugItInGame {
        get { getGame() as! PlugItInGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PlugItInDocument.sharedInstance }
    var rng = [PlugItInObject]()
    
    override func copy() -> PlugItInGameState {
        let v = PlugItInGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PlugItInGameState) -> PlugItInGameState {
        _ = super.setup(v: v)
        v.rng = rng
        return v
    }
    
    required init(game: PlugItInGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        rng = Array<PlugItInObject>(repeating: PlugItInObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> PlugItInObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PlugItInObject {
        get { rng[row * cols + col] }
        set { rng[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout PlugItInGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + PlugItInGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 6/Plug it in

        Summary
        Give them light

        Description
        1. Connect each battery with a lightbulb by a horizontal or vertical cable.
        2. Cables are not allowed to cross other cables.
    */
    private func updateIsSolved() {
        isSolved = true
        var rng = [Position]()
        var ch2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let ch = game[p]
                let dirs = (0..<4).filter { o[$0] }
                ch2dirs[p] = dirs
                let cnt = dirs.count
                if ch == " " {
                    // 2. Links must be straight lines, not crossing each other.
                    guard cnt == 0 || (cnt == 2 && (dirs[0] + 2) % 4 == dirs[1]) else { isSolved = false; return }
                    if cnt == 2 { rng.append(p) }
                } else {
                    guard cnt > 0 else { isSolved = false; return }
                    rng.append(p)
                }
            }
        }
        // 1. Make Cappuccino by linking each cup to one or more coffee beans and cows.
        // 4. When linking multiple beans and cows, you can also link cows to cows and
        //    beans to beans, other than linking them to the cup.
        let g = Graph()
        var pos2node = [Position: Node]()
        for p in rng {
            pos2node[p] = g.addNode(p.description)
        }
        for p in rng {
            for i in 0..<4 {
                guard self[p][i] else {continue}
                guard let node2 = pos2node[p + PlugItInGame.offset[i]] else { isSolved = false; return }
                g.addEdge(pos2node[p]!, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let nBean = area.count { game[$0] == PlugItInGame.PUZ_BEAN }
            let nCup = area.count { game[$0] == PlugItInGame.PUZ_CUP }
            let nMilk = area.count { game[$0] == PlugItInGame.PUZ_MILK }
            // 3. To each cup there must be linked an equal number of beans and cows. At
            //    least one of each.
            guard nCup == 1 && nBean > 0 && nBean == nMilk else { isSolved = false; return }
        }
    }
}
