//
//  GardenTunnelsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GardenTunnelsGameState: GridGameState<GardenTunnelsGameMove> {
    var game: GardenTunnelsGame {
        get { getGame() as! GardenTunnelsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { GardenTunnelsDocument.sharedInstance }
    var objArray = [GardenTunnelsObject]()
    var pos2state = [Position: HintState]()

    override func copy() -> GardenTunnelsGameState {
        let v = GardenTunnelsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: GardenTunnelsGameState) -> GardenTunnelsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: GardenTunnelsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<GardenTunnelsObject>(repeating: GardenTunnelsObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> GardenTunnelsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GardenTunnelsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout GardenTunnelsGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + GardenTunnelsGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 4/Garden Tunnels

        Summary
        Whack a mole

        Description
        1. the board represents a few gardens where some moles are digging
           straight line tunnels.
        2. Each tunnel starts in the garden and ends in a different garden,
           and can pass through other gardens.
        3. The number in the garden tells you how many tunnels start/end in that
           garden.
        4. The entire board must be filled with tunnels.
    */
    private func updateIsSolved() {
        isSolved = true
        var rng = [Position]()
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                pos2dirs[p] = dirs
                let cnt = dirs.count
                if cnt == 1 || cnt == 2 {
                    rng.append(p)
                    if cnt == 2 {
                        // 1. the board represents a few gardens where some moles are digging
                        //    straight line tunnels.
                        if dirs[1] - dirs[0] != 2 { isSolved = false }
                    }
                } else {
                    // 4. The entire board must be filled with tunnels.
                    isSolved = false
                }
            }
        }
        // 3. The number in the garden tells you how many tunnels start/end in that
        //    garden.
        for area in game.areas {
            guard let pHint = area.first(where: { game.pos2hint[$0] != nil }) else {continue}
            let n2 = game.pos2hint[pHint]!
            let n1 = area.count { pos2dirs[$0]!.count == 1 }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s != .complete { isSolved = false }
            pos2state[pHint] = s
        }
        guard !isSolved else {return}
        // 2. Each tunnel starts in the garden and ends in a different garden,
        //    and can pass through other gardens.
        let g = Graph()
        var pos2node = [Position: Node]()
        for p in rng {
            pos2node[p] = g.addNode(p.description)
        }
        for p in rng {
            for i in 0..<4 {
                guard self[p][i] else {continue}
                guard let node2 = pos2node[p + GardenTunnelsGame.offset[i]] else { isSolved = false; return }
                g.addEdge(pos2node[p]!, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let tunnel = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            guard tunnel.count(where: { !pos2dirs[$0]!.isEmpty }) >= 2 else { isSolved = false; return }
        }
    }
}
