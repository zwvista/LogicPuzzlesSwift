//
//  AbstractPaintingGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class AbstractPaintingGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: AbstractPaintingGame {
        get {getGame() as! AbstractPaintingGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: AbstractPaintingDocument { AbstractPaintingDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { AbstractPaintingDocument.sharedInstance }
    var objArray = [AbstractPaintingObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> AbstractPaintingGameState {
        let v = AbstractPaintingGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: AbstractPaintingGameState) -> AbstractPaintingGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: AbstractPaintingGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<AbstractPaintingObject>(repeating: AbstractPaintingObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> AbstractPaintingObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> AbstractPaintingObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func setObject(move: inout AbstractPaintingGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        // 3. The region of the painting can be entirely hidden or revealed.
        for p2 in game.areas[game.pos2area[p]!] {
            self[p2] = move.obj
        }
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout AbstractPaintingGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: AbstractPaintingObject) -> AbstractPaintingObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .painting
            case .painting:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .painting : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 16/Abstract Painting

        Summary
        Abstract Logic

        Description
        1. The goal is to reveal part of the abstract painting behind the board.
        2. Outer numbers tell how many tiles form the painting on the row and column.
        3. The region of the painting can be entirely hidden or revealed.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if self[r, c] == .forbidden {self[r, c] = .empty}
            }
        }
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if self[r, c] == .painting {n1 += 1}
            }
            // 2. Outer numbers tell how many tiles form the painting on the row.
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            row2state[r] = s
            if s != .complete {isSolved = false}
        }
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if self[r, c] == .painting {n1 += 1}
            }
            // 2. Outer numbers tell how many tiles form the painting on the column.
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            col2state[c] = s
            if s != .complete {isSolved = false}
        }
        for r in 0..<rows {
            for c in 0..<cols {
                switch self[r, c] {
                case .empty, .marker:
                    if allowedObjectsOnly && (row2state[r] != .normal && game.row2hint[r] != -1 || col2state[c] != .normal && game.col2hint[c] != -1) {self[r, c] = .forbidden}
                default:
                    break
                }
            }
        }
    }
}
