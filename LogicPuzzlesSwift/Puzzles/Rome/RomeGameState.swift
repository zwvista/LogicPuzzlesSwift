//
//  RomeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class RomeGameState: GridGameState<RomeGameMove> {
    var game: RomeGame {
        get { getGame() as! RomeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { RomeDocument.sharedInstance }
    var objArray = [RomeObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> RomeGameState {
        let v = RomeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: RomeGameState) -> RomeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: RomeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> RomeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> RomeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout RomeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout RomeGameMove) -> GameOperationType {
        func f(o: RomeObject) -> RomeObject {
            switch o {
            case .empty:
                return .up
            case .up:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 2/Rome

        Summary
        All roads lead to ...

        Description
        1. All the roads lead to Rome.
        2. Hence you should fill the remaining spaces with arrows and in the
           end, starting at any tile and following the arrows, you should get
           at the Rome icon.
        3. Arrows in an area should all be different, i.e. there can't be two
           similar arrows in an area.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        var oLast: RomeObject = .empty
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
