//
//  MagnetsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MagnetsGameState: GridGameState<MagnetsGame, MagnetsDocument> {
    override var gameDocument: MagnetsDocument { MagnetsDocument.sharedInstance }
    var objArray = [MagnetsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> MagnetsGameState {
        let v = MagnetsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MagnetsGameState) -> MagnetsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: MagnetsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MagnetsObject>(repeating: MagnetsObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows * 2)
        col2state = Array<HintState>(repeating: .normal, count: cols * 2)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MagnetsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MagnetsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func setObject(move: inout MagnetsGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && !game.singles.contains(p) && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout MagnetsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: MagnetsObject) -> MagnetsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .positive
            case .positive:
                return .negative
            case .negative:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .positive : .empty
            }
        }
        let p = move.p
        guard isValid(p: p) else { return false }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 2/Magnets

        Summary
        Place Magnets on the board, respecting the orientation of poles

        Description
        1. Each Magnet has a positive(+) and a negative(-) pole.
        2. Every rectangle can either contain a Magnet or be empty.
        3. The number on the board tells you how many positive and negative poles
           you can see from there in a straight line.
        4. When placing a Magnet, you have to respect the rule that the same pole
           (+ and + / - and -) can't be adjacent horizontally or vertically.
        5. In some levels, a few numbers on the border can be hidden.
    */
    private func updateIsSolved() {
        isSolved = true
        // 3. The number on the board tells you how many positive and negative poles
        // you can see from there in a straight line.
        for r in 0..<rows {
            var (np1, nn1) = (0, 0)
            let (np2, nn2) = (game.row2hint[r * 2], game.row2hint[r * 2 + 1])
            for c in 0..<cols {
                switch self[r, c] {
                case .positive:
                    np1 += 1
                case .negative:
                    nn1 += 1
                default:
                    break
                }
            }
            row2state[r * 2] = np1 < np2 ? .normal : np1 == np2 ? .complete : .error
            row2state[r * 2 + 1] = nn1 < nn2 ? .normal : nn1 == nn2 ? .complete : .error
            if np1 != np2 || nn1 != nn2 { isSolved = false }
        }
        // 3. The number on the board tells you how many positive and negative poles
        // you can see from there in a straight line.
        for c in 0..<cols {
            var (np1, nn1) = (0, 0)
            let (np2, nn2) = (game.col2hint[c * 2], game.col2hint[c * 2 + 1])
            for r in 0..<rows {
                switch self[r, c] {
                case .positive:
                    np1 += 1
                case .negative:
                    nn1 += 1
                default:
                    break
                }
            }
            col2state[c * 2] = np1 < np2 ? .normal : np1 == np2 ? .complete : .error
            col2state[c * 2 + 1] = nn1 < nn2 ? .normal : nn1 == nn2 ? .complete : .error
            if np1 != np2 || nn1 != nn2 { isSolved = false }
        }
        guard isSolved else {return}
        // 2. Every rectangle can either contain a Magnet or be empty.
        for a in game.areas {
            switch a.type {
            case .single:
                continue
            case .horizontal, .vertical:
                let os = MagnetsGame.offset[a.type == .horizontal ? 1 : 2]
                let (o1, o2) = (self[a.p], self[a.p + os])
                if o1.isEmpty() != o2.isEmpty() {
                    isSolved = false; return
                }
            }
        }
        // 1. Each Magnet has a positive(+) and a negative(-) pole.
        // 4. When placing a Magnet, you have to respect the rule that the same pole
        // (+ and + / - and -) can't be adjacent horizontally or vertically.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[r, c]
                for os in MagnetsGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2) else {continue}
                    let o2 = self[p2]
                    if o.isPole() && o == o2 {
                        isSolved = false; return
                    }
                }
            }
        }
    }
}
