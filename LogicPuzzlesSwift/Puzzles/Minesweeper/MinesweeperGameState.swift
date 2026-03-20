//
//  MinesweeperGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MinesweeperGameState: GridGameState<MinesweeperGameMove> {
    var game: MinesweeperGame {
        get { getGame() as! MinesweeperGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MinesweeperDocument.sharedInstance }
    var objArray = [MinesweeperObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> MinesweeperGameState {
        let v = MinesweeperGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MinesweeperGameState) -> MinesweeperGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MinesweeperGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MinesweeperObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> MinesweeperObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MinesweeperObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MinesweeperGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != .hint && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout MinesweeperGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != .hint else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .mine
        case .mine: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .mine : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 6/Minesweeper

        Summary
        You know the drill :)

        Description
        1. Find the mines on the field.
        2. Numbers tell you how many mines there are close by, touching that
           number horizontally, vertically or diagonally.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if case .forbidden = self[p] { self[p] = .empty }
            }
        }
        for (p, n2) in game.pos2hint {
            var n1 = 0
            var rng = [Position]()
            for os in MinesweeperGame.offset {
                let p2 = p + os
                guard game.isValid(p: p2) else {continue}
                switch self[p2] {
                case .mine:
                    n1 += 1
                case .empty:
                    rng.append(p2)
                default:
                    break
                }
            }
            // 2. Numbers tell you how many mines there are close by, touching that
            // number horizontally, vertically or diagonally.
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete {
                isSolved = false
            } else if allowedObjectsOnly {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
    }
}
