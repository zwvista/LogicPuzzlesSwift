//
//  GuessTheLabyrinthGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GuessTheLabyrinthGameState: GridGameState<GuessTheLabyrinthGameMove> {
    var game: GuessTheLabyrinthGame {
        get { getGame() as! GuessTheLabyrinthGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { GuessTheLabyrinthDocument.sharedInstance }
    var objArray = [GridDotObject]()
    
    override func copy() -> GuessTheLabyrinthGameState {
        let v = GuessTheLabyrinthGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: GuessTheLabyrinthGameState) -> GuessTheLabyrinthGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: GuessTheLabyrinthGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> GridDotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout GuessTheLabyrinthGameMove) -> GameOperationType {
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let dir = move.dir, dir2 = (dir + 2) % 4
        let p = move.p, p2 = p + GuessTheLabyrinthGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout GuessTheLabyrinthGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[move.p][move.dir]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .line
        case .line: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .line : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 4/Guess the Labyrinth

        Summary
        Before solving it

        Description
        1. There is a hidden Labyrinth in the board.
        2. The Labyrinth is a one-square wide path which doesn't branch out and
           that forms a closed loop
        3. The intersections where three lines meet are marked with a dot
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] == .line }
                // 3. The intersections where three lines meet are marked with a dot
                if (dirs.count == 3) != game.posts.contains(p) {
                    isSolved = false; return
                }
            }
        }
        // 2. The Labyrinth is a one-square wide path which doesn't branch out and
        //    that forms a closed loop
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                let dirs = (0..<4).filter {
                    self[p + GuessTheLabyrinthGame.offset2[$0]][GuessTheLabyrinthGame.dirs[$0]] != .line
                }
                if dirs.count != 2 { isSolved = false; return }
                pos2dirs[p] = dirs
            }
        }
        // Check the loop
        let p = pos2dirs.keys.first!
        var p2 = p, n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += GuessTheLabyrinthGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
