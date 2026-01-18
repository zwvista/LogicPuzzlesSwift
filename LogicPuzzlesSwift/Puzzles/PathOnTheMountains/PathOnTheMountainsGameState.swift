//
//  PathOnTheMountainsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PathOnTheMountainsGameState: GridGameState<PathOnTheMountainsGameMove> {
    var game: PathOnTheMountainsGame {
        get { getGame() as! PathOnTheMountainsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PathOnTheMountainsDocument.sharedInstance }
    var objArray = [PathOnTheMountainsObject]()
    
    override func copy() -> PathOnTheMountainsGameState {
        let v = PathOnTheMountainsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PathOnTheMountainsGameState) -> PathOnTheMountainsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PathOnTheMountainsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<PathOnTheMountainsObject>(repeating: PathOnTheMountainsObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> PathOnTheMountainsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PathOnTheMountainsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout PathOnTheMountainsGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + PathOnTheMountainsGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && game[p] != PathOnTheMountainsGame.PUZ_BLOCK && game[p2] != PathOnTheMountainsGame.PUZ_BLOCK else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 5/Path on the Mountains

        Summary
        Turn on the peak, turn on the plain

        Description
        1. Fill the board with a loop that passes through all tiles.
        2. The path should make 90 degrees turns on the spots.
        3. Between spots, the path makes one more 90 degrees turn.
        4. So the path alternates turning on spots and outside them.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2Dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    // 1. Draw a loop that runs through all tiles.
                    pos2Dirs[p] = dirs
                } else if !(dirs.isEmpty && game[p] == PathOnTheMountainsGame.PUZ_BLOCK) {
                    // 2. The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        let p = pos2Dirs.keys.first!
        var p2 = p, n = -1
        while true {
            guard let dirs = pos2Dirs[p2] else { isSolved = false; return }
            pos2Dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += PathOnTheMountainsGame.offset[n]
            guard p2 != p else {return}
        }
    }
}
