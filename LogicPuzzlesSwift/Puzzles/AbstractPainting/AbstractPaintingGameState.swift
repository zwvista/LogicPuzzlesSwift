//
//  AbstractPaintingGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class AbstractPaintingGameState: GridGameState<AbstractPaintingGameMove> {
    var game: AbstractPaintingGame {
        get { getGame() as! AbstractPaintingGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { AbstractPaintingDocument.sharedInstance }
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
    
    override func setObject(move: inout AbstractPaintingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        // 3. The region of the painting can be entirely hidden or revealed.
        for p2 in game.areas[game.pos2area[p]!] {
            self[p2] = move.obj
        }
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout AbstractPaintingGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .painting
        case .painting: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .painting : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 4/Abstract Mirror Painting

        Summary
        Aliens, move over, the Next Trend is here!

        Description
        1. Diagonal mirrors are out, the new trend is orthogonal mirror abstract painting!
        2. You should paint areas that span two adjacent regions. The area is symmetrical with respect
           to the regions border.
        3. Numbers tell you how many tiles in that region are painted.
        4. Areas can't touch orthogonally.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if self[r, c] == .forbidden { self[r, c] = .empty }
            }
        }
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if self[r, c] == .painting { n1 += 1 }
            }
            // 2. Outer numbers tell how many tiles form the painting on the row.
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
        }
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if self[r, c] == .painting { n1 += 1 }
            }
            // 2. Outer numbers tell how many tiles form the painting on the column.
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                switch self[r, c] {
                case .empty, .marker:
                    if allowedObjectsOnly && (row2state[r] != .normal && game.row2hint[r] != -1 || col2state[c] != .normal && game.col2hint[c] != -1) { self[r, c] = .forbidden }
                default:
                    break
                }
            }
        }
    }
}
