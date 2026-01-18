//
//  WallsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class WallsGameState: GridGameState<WallsGameMove> {
    var game: WallsGame {
        get { getGame() as! WallsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { WallsDocument.sharedInstance }
    var objArray = [WallsObject]()
    
    override func copy() -> WallsGameState {
        let v = WallsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: WallsGameState) -> WallsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: WallsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<WallsObject>(repeating: .empty, count: rows * cols)
        for (p, _) in game.pos2hint {
            self[p] = .hint()
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> WallsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> WallsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout WallsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil, String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout WallsGameMove) -> GameOperationType {
        func f(o: WallsObject) -> WallsObject {
            switch o {
            case .empty: return .horz
            case .horz: return .vert
            case .vert: return .empty
            default: return o
            }
        }
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 5/Walls

        Summary
        Find the maze of Bricks

        Description
        1. In Walls you must fill the board with straight horizontal and
           vertical lines (walls) that stem from each number.
        2. The number itself tells you the total length of Wall segments
           connected to it.
        3. Wall pieces have two ways to be put, horizontally or vertically.
        4. Not every wall piece must be connected with a number, but the
           board must be filled with wall pieces.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .empty:
                    // 1. In Walls you must fill the board with straight horizontal and
                    // vertical lines (walls) that stem from each number.
                    // 4. Not every wall piece must be connected with a number, but the
                    // board must be filled with wall pieces.
                    isSolved = false
                case .hint:
                    let n2 = game.pos2hint[p]!
                    var n1 = 0
                    for i in 0..<4 {
                        let os = WallsGame.offset[i]
                        var p2 = p + os
                        while isValid(p: p2) {
                            if i % 2 == 0 {
                                // 3. Wall pieces have two ways to be put, horizontally or vertically.
                                if case .vert = self[p2] {
                                    n1 += 1
                                } else {
                                    break
                                }
                            } else {
                                // 3. Wall pieces have two ways to be put, horizontally or vertically.
                                if case .horz = self[p2] {
                                    n1 += 1
                                } else {
                                    break
                                }
                            }
                            p2 += os
                        }
                    }
                    // 2. The number itself tells you the total length of Wall segments
                    // connected to it.
                    let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
                    if s != .complete { isSolved = false }
                    self[p] = .hint(state: s)
                default:
                    break
                }
            }
        }
    }
}
