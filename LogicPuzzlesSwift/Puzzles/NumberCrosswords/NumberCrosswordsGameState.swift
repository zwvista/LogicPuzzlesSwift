//
//  NumberCrosswordsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NumberCrosswordsGameState: GridGameState<NumberCrosswordsGameMove> {
    var game: NumberCrosswordsGame {
        get { getGame() as! NumberCrosswordsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { NumberCrosswordsDocument.sharedInstance }
    var objArray = [NumberCrosswordsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> NumberCrosswordsGameState {
        let v = NumberCrosswordsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NumberCrosswordsGameState) -> NumberCrosswordsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: NumberCrosswordsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<NumberCrosswordsObject>(repeating: NumberCrosswordsObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .error, count: rows - 1)
        col2state = Array<HintState>(repeating: .error, count: cols - 1)
        updateIsSolved()
    }
    
    subscript(p: Position) -> NumberCrosswordsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> NumberCrosswordsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout NumberCrosswordsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout NumberCrosswordsGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: NumberCrosswordsObject) -> NumberCrosswordsObject {
            switch o {
            case .normal:
                return markerOption == .markerFirst ? .marker : .darken
            case .darken:
                return markerOption == .markerLast ? .marker : .normal
            case .marker:
                return markerOption == .markerFirst ? .darken : .normal
            }
        }
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games 2/Puzzle Set 1/Number Crosswords

        Summary
        More crosswords for Robots

        Description
        1. Blacken some tiles, so that some of the numbers remain visible.
        2. Numbers outside the grid show the states of the numbers in the
           remaining tiles in that row or column.
    */
    private func updateIsSolved() {
        isSolved = true
        // 1. Blacken some tiles, so that some of the numbers remain visible.
        // 2. Numbers outside the grid show the states of the numbers in the
        //    remaining tiles in that row or column.
        for r in 0..<rows - 1 {
            var sum = 0
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                guard self[p] != .darken else {continue}
                sum += game[p]
            }
            row2state[r] = sum == game[r, cols - 1] ? .complete : .error
            if row2state[r] != .complete { isSolved = false }
        }
        // 1. Blacken some tiles, so that some of the numbers remain visible.
        // 2. Numbers outside the grid show the states of the numbers in the
        //    remaining tiles in that row or column.
        for c in 0..<cols - 1 {
            var sum = 0
            for r in 0..<rows - 1 {
                let p = Position(r, c)
                guard self[p] != .darken else {continue}
                sum += game[p]
            }
            col2state[c] = sum == game[rows - 1, c] ? .complete : .error
            if col2state[c] != .complete { isSolved = false }
        }
    }
}
