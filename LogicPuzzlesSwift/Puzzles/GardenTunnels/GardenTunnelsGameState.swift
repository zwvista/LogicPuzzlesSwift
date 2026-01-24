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
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    pos2dirs[p] = dirs
                    if game[p] != " " {
                        // 2. The path should make 90 degrees turns on the spots.
                        guard dirs[1] - dirs[0] != 2 else { isSolved = false; return }
                    }
                } else {
                    // 1. Fill the board with a loop that passes through all tiles.
                    // The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        guard let p = pos2dirs.keys.first(where: { game[$0] != " " }) else { isSolved = false; return }
        var p2 = p
        var n = -1, ns = [Int]()
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            ns.append(n)
            p2 += GardenTunnelsGame.offset[n]
            if game[p2] != " " {
                // 3. Between spots, the path makes one more 90 degrees turn.
                let turns = (0..<ns.count - 1).count { ns[$0] != ns[$0 + 1] }
                guard turns == 1 else { isSolved = false; return }
                ns.removeAll()
            }
            guard p2 != p else {return}
        }
    }
}
