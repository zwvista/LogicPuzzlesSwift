//
//  InbetweenSumscrapersGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class InbetweenSumscrapersGameState: GridGameState<InbetweenSumscrapersGameMove> {
    var game: InbetweenSumscrapersGame {
        get { getGame() as! InbetweenSumscrapersGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { InbetweenSumscrapersDocument.sharedInstance }
    var objArray = [Int]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var pos2state = [Position: AllowedObjectState]()
    
    override func copy() -> InbetweenSumscrapersGameState {
        let v = InbetweenSumscrapersGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: InbetweenSumscrapersGameState) -> InbetweenSumscrapersGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: InbetweenSumscrapersGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout InbetweenSumscrapersGameMove) -> GameOperationType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        guard String(describing: o1) != String(describing: o2) else { return .invalid }
        self[p] = o2
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout InbetweenSumscrapersGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let o = self[p]
        // 3. The remaining cells contain numbers increasing from 1 to N-2 (N being
        //    the board size).
        move.obj = o == rows - 2 ? InbetweenSumscrapersGame.PUZ_SKYSCRAPER : o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 6/Inbetween Sumscrapers

        Summary
        Sumscrapers on the ground

        Description
        1. Find two Skyscrapers and fill the remaining cells with numbers.
        2. Each row and column contains two skyscrapers.
        3. The remaining cells contain numbers increasing from 1 to N-2 (N being
           the board size).
        4. Numbers appear once in every row and column.
        5. Hints on the border give you the sums of the numbers between the skyscrapers.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        for r in 0..<rows {
            var skyscrapers = [Position]()
            var num2rng = [Int: [Position]]()
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p]
                switch n {
                case InbetweenSumscrapersGame.PUZ_SKYSCRAPER:
                    skyscrapers.append(p)
                case InbetweenSumscrapersGame.PUZ_EMPTY:
                    isSolved = false
                default:
                    num2rng[n, default: []].append(p)
                }
            }
            for (_, rng) in num2rng {
                let cnt = rng.count
                guard cnt > 1 else {continue}
                isSolved = false
                for p in rng { pos2state[p] = .error }
            }
            let n1 = skyscrapers.count, n2 = game.row2hint[r]
            // 2. Each row and column contains two skyscrapers.
            if n1 > 2 {
                for p in skyscrapers { pos2state[p] = .error }
            }
            guard n2 != InbetweenSumscrapersGame.PUZ_UNKNOWN else {continue}
            // 3. The remaining cells contain numbers increasing from 1 to N-2 (N being
            //    the board size).
            // 4. Numbers appear once in every row and column.
            // 5. Hints on the border give you the sums of the numbers between the skyscrapers.
            let s: HintState = n1 < 2 ? .normal : n1 == 2 && n2 == (skyscrapers[0].col + 1..<skyscrapers[1].col).reduce(0) { [unowned self] acc, c in acc + self[r, c] } ? .complete : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
        }
        for c in 0..<cols {
            var skyscrapers = [Position]()
            var num2rng = [Int: [Position]]()
            for r in 0..<rows {
                let p = Position(r, c)
                let n = self[p]
                switch n {
                case InbetweenSumscrapersGame.PUZ_SKYSCRAPER:
                    skyscrapers.append(p)
                case InbetweenSumscrapersGame.PUZ_EMPTY:
                    isSolved = false
                default:
                    num2rng[n, default: []].append(p)
                }
            }
            for (_, rng) in num2rng {
                let cnt = rng.count
                guard cnt > 1 else {continue}
                isSolved = false
                for p in rng { pos2state[p] = .error }
            }
            let n1 = skyscrapers.count, n2 = game.col2hint[c]
            // 2. Each row and column contains two skyscrapers.
            if n1 > 2 {
                for p in skyscrapers { pos2state[p] = .error }
            }
            guard n2 != InbetweenSumscrapersGame.PUZ_UNKNOWN else {continue}
            // 3. The remaining cells contain numbers increasing from 1 to N-2 (N being
            //    the board size).
            // 4. Numbers appear once in every row and column.
            // 5. Hints on the border give you the sums of the numbers between the skyscrapers.
            let s: HintState = n1 < 2 ? .normal : n1 == 2 && n2 == (skyscrapers[0].row + 1..<skyscrapers[1].row).reduce(0) { [unowned self] acc, r in acc + self[r, c] } ? .complete : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
        }
    }
}
