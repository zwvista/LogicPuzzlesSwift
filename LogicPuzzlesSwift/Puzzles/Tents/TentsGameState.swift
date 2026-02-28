//
//  TentsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TentsGameState: GridGameState<TentsGameMove> {
    var game: TentsGame {
        get { getGame() as! TentsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TentsDocument.sharedInstance }
    var objArray = [TentsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> TentsGameState {
        let v = TentsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TentsGameState) -> TentsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: TentsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TentsObject>(repeating: TentsObject(), count: rows * cols)
        for p in game.pos2tree {
            self[p] = .tree()
        }
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> TentsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TentsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TentsGameMove) -> GameOperationType {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TentsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .tent()
        case .tent: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .tent() : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 1/Tents

        Summary
        Each camper wants his shade. But his privacy too!

        Description
        1. The board represents a camping field with many Trees. Campers want to set
           their Tent in the shade, horizontally or vertically adjacent to a Tree(not
           diagonally).
        2. At the same time they need their privacy, so a Tent can't have any other
           Tents near them, not even diagonally.
        3. The numbers on the borders tell you how many Tents there are in that row
           or column.
        4. Finally, keep in mind these two rules:
        5. Each Tree has at least one Tent touching it, horizontally or vertically.
        6. There's the same exact numbers of Trees and Tents in the Camping Area.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if case .tent = self[r, c] { n1 += 1 }
            }
            // 3. The numbers on the borders tell you how many Tents there are in that row.
            let s: HintState = n2 == TentsGame.PUZ_UNKNOWN || n1 == n2 ? .complete : n1 < n2 ? .normal : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
        }
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if case .tent = self[r, c] { n1 += 1 }
            }
            // 3. The numbers on the borders tell you how many Tents there are in that column.
            let s: HintState = n2 == TentsGame.PUZ_UNKNOWN || n1 == n2 ? .complete : n1 < n2 ? .normal : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] { self[r, c] = .empty }
            }
        }
        var nTree = 0, nTent = 0
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasTree() -> Bool {
                    for os in TentsGame.offset {
                        let p2 = p + os
                        if isValid(p: p2), case .tree = self[p2] { return true }
                    }
                    return false
                }
                func hasTent(isTree: Bool) -> Bool {
                    for os in isTree ? TentsGame.offset : TentsGame.offset2 {
                        let p2 = p + os
                        if isValid(p: p2), case .tent = self[p2] { return true }
                    }
                    return false
                }
                switch self[p] {
                case .tent:
                    nTent += 1
                    // 1. The board represents a camping field with many Trees. Campers want to set
                    // their Tent in the shade, horizontally or vertically adjacent to a Tree(not
                    // diagonally).
                    // 2. At the same time they need their privacy, so a Tent can't have any other
                    // Tents near them, not even diagonally.
                    let s: AllowedObjectState = hasTree() && !hasTent(isTree: false) ? .normal : .error
                    self[p] = .tent(state: s)
                    if s == .error { isSolved = false }
                case .tree:
                    nTree += 1
                    // 5. Each Tree has at least one Tent touching it, horizontally or vertically.
                    let s: AllowedObjectState = hasTent(isTree: true) ? .normal : .error
                    self[p] = .tree(state: s)
                    if s == .error { isSolved = false }
                case .empty, .marker:
                    guard allowedObjectsOnly else {break}
                    if col2state[c] != .normal && game.col2hint[c] != TentsGame.PUZ_UNKNOWN || row2state[r] != .normal && game.row2hint[r] != TentsGame.PUZ_UNKNOWN || !hasTree() || hasTent(isTree: false) { self[p] = .forbidden }
                default:
                    break
                }
            }
        }
        // 6. There's the same exact numbers of Trees and Tents in the Camping Area.
        if nTree != nTent { isSolved = false }
    }
}
