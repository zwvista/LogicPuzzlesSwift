//
//  TheMagicNumberGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TheMagicNumberGameState: GridGameState<TheMagicNumberGameMove> {
    var game: TheMagicNumberGame {
        get { getGame() as! TheMagicNumberGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TheMagicNumberDocument.sharedInstance }
    var objArray = [TheMagicNumberObject]()
    var pos2state = [Position: AllowedObjectState]()
    
    override func copy() -> TheMagicNumberGameState {
        let v = TheMagicNumberGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TheMagicNumberGameState) -> TheMagicNumberGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TheMagicNumberGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> TheMagicNumberObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TheMagicNumberObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TheMagicNumberGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TheMagicNumberGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: .fv1
        case .fv1: .fv2
        case .fv2: .fv3
        case .fv3: .empty
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 3/The Magic Number

        Summary
        No more, no less, you don't have to guess

        Description
        1. Fill the board with 3 different symbols.
        2. On side-6 boards there will be 2 of each on any row or column.
        3. On side-9 boards there will be 3 of each on any row or column.
        4. On side-12 boards there will be 4 of each on any row or column.
        5. When a tile has a shaded background, the symbols around it must
           be different.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 2. On side-6 boards there will be 2 of each on any row or column.
        // 3. On side-9 boards there will be 3 of each on any row or column.
        // 4. On side-12 boards there will be 4 of each on any row or column.
        func checkSymbols(symbol2range: [TheMagicNumberObject: [Position]]) {
            for (_, range) in symbol2range {
                let cnt = range.count
                if cnt != game.symbolCountPerRowCol {
                    isSolved = false
                    if cnt > game.symbolCountPerRowCol {
                        for p in range { pos2state[p] = .error }
                    }
                }
            }
        }
        for r in 0..<rows {
            var symbol2range = [TheMagicNumberObject: [Position]]()
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                guard o != .empty else { isSolved = false; continue }
                symbol2range[o, default: []].append(p)
            }
            checkSymbols(symbol2range: symbol2range)
        }
        for c in 0..<cols {
            var symbol2range = [TheMagicNumberObject: [Position]]()
            for r in 0..<rows {
                let p = Position(r, c)
                let o = self[p]
                if (o == .empty) {
                    isSolved = false
                } else {
                    symbol2range[o, default: []].append(p)
                }
            }
            checkSymbols(symbol2range: symbol2range)
        }
        // 5. When a tile has a shaded background, the symbols around it must
        //    be different.
        for p in game.shaded {
            let o = self[p]
            guard o != .empty else {continue}
            for os in TheMagicNumberGame.offset {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                if self[p2] == o {
                    isSolved = false
                    pos2state[p] = .error
                    pos2state[p2] = .error
                }
            }
        }
    }
}
