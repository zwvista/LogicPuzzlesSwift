//
//  LandscaperGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LandscaperGameState: GridGameState<LandscaperGameMove> {
    var game: LandscaperGame {
        get { getGame() as! LandscaperGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LandscaperDocument.sharedInstance }
    var objArray = [LandscaperObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> LandscaperGameState {
        let v = LandscaperGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LandscaperGameState) -> LandscaperGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: LandscaperGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> LandscaperObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LandscaperObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout LandscaperGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout LandscaperGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = o == .empty ? .tree : o == .tree ? .flower : .empty
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 4/Landscaper

        Summary
        Plant Trees and Flowers with enough variety

        Description
        1. Your goal as a landscaper is to plant some Trees and Flowers on the
           field, in every available tile.
        2. In doing this, you must assure the scenery is varied enough:
        3. No more than two consecutive Trees or Flowers should appear horizontally
           or vertically.
        4. Every row and column should have an equal number of Trees and Flowers.
        5. Each row disposition must be unique, i.e. the same arrangement of Trees
           and Flowers can't appear on two rows.
        6. Each column disposition must be unique as well.

        Odd-size levels
        7. Please note that in odd-size levels, the number of Trees and Flowers
           obviously won't be equal on a row or column. However each row and
           column will have the same number of Flowers and Trees.
        8. Also, the number of Trees will always be greater than that of Flowers
           (i.e. 3 Flowers and 4 Trees, 4 Flowers and 5 Trees, etc).
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        var oLast: LandscaperObject = .empty
        var tokens = [Position]()
        func checkTokens() {
            if tokens.count > 3 {
                isSolved = false
                for p in tokens {
                    pos2state[p] = .error
                }
            }
            tokens.removeAll()
        }
        for r in 0..<rows {
            oLast = .empty
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                if o != oLast {
                    checkTokens()
                    oLast = o
                }
                if o == .empty {
                    isSolved = false
                } else {
                    tokens.append(p)
                }
            }
            checkTokens()
        }
        for c in 0..<cols {
            oLast = .empty
            for r in 0..<rows {
                let p = Position(r, c)
                let o = self[p]
                if o != oLast {
                    checkTokens()
                    oLast = o
                }
                if o == .empty {
                    isSolved = false
                } else {
                    tokens.append(p)
                }
            }
            checkTokens()
        }
    }
}
