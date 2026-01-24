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
    var pos2state = [Position: HintState]()

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
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                pos2dirs[p] = dirs
                if !(dirs.count == 2 || dirs.isEmpty) { isSolved = false }
            }
        }
        for (p, n2) in game.pos2hint {
            let area = game.areas[game.pos2area[p]!]
            let n1 = area.reduce(0) { acc, p in acc + (pos2dirs[p]!.isEmpty ? 0 : 1) }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s != .complete { isSolved = false }
            pos2state[p] = s
        }
        guard isSolved else {return}
        // Check the loop
        guard let p = pos2dirs.keys.first else { isSolved = false; return }
        var p2 = p
        var n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += PathOnTheHillsGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
