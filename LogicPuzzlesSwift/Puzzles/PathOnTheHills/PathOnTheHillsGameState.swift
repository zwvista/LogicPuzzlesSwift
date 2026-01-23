//
//  PathOnTheHillsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PathOnTheHillsGameState: GridGameState<PathOnTheHillsGameMove> {
    var game: PathOnTheHillsGame {
        get { getGame() as! PathOnTheHillsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PathOnTheHillsDocument.sharedInstance }
    var objArray = [PathOnTheHillsObject]()
    
    override func copy() -> PathOnTheHillsGameState {
        let v = PathOnTheHillsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PathOnTheHillsGameState) -> PathOnTheHillsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PathOnTheHillsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<PathOnTheHillsObject>(repeating: PathOnTheHillsObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> PathOnTheHillsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PathOnTheHillsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout PathOnTheHillsGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + PathOnTheHillsGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Path on the Hills

        Summary
        Up for a little exercise?

        Description
        1. The board represents a map of the Countryside, divided in Fields.
        2. The object is to have a walk around the Countryside, passing through
           each Field just once.
        3. the number on a Field tells you how many tiles you should go through it.
        4. A Field with no number can be passed through in any number of tiles,
           at least one.
        5. If you avoid two adjacent tiles in your path, they should be in the
           same Fields.
        6. Or in other words, two adjacent empty tiles cannot be in two different
           Fields.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2Dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    pos2Dirs[p] = dirs
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
        guard let p = pos2Dirs.keys.first(where: { game[$0] != " " }) else { isSolved = false; return }
        var p2 = p
        var n = -1, ns = [Int]()
        while true {
            guard let dirs = pos2Dirs[p2] else { isSolved = false; return }
            pos2Dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            ns.append(n)
            p2 += PathOnTheHillsGame.offset[n]
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
