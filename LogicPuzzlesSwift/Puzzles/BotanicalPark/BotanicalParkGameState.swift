//
//  BotanicalParkGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BotanicalParkGameState: GridGameState<BotanicalParkGameMove> {
    var game: BotanicalParkGame {
        get { getGame() as! BotanicalParkGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { BotanicalParkDocument.sharedInstance }
    var objArray = [BotanicalParkObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> BotanicalParkGameState {
        let v = BotanicalParkGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BotanicalParkGameState) -> BotanicalParkGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: BotanicalParkGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BotanicalParkObject>(repeating: BotanicalParkObject(), count: rows * cols)
        for (p, _) in game.pos2arrow {
            self[p] = .arrow(state: .normal)
        }
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> BotanicalParkObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> BotanicalParkObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout BotanicalParkGameMove) -> GameOperationType {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout BotanicalParkGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: BotanicalParkObject) -> BotanicalParkObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tree(state: .normal)
            case .tree:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tree(state: .normal) : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 12/Botanical Park

        Summary
        Excuse me sir ? Do you know where the Harpagophytum Procumbens is ?

        Description
        1. The board represents a Botanical Park, with arrows pointing to the
           different plants.
        2. Each arrow points to at least one plant and there is exactly one
           plant in every row and in every column.
        3. Plants cannot touch, not even diagonally.

        Variant
        4. Puzzle with side 9 or bigger have TWO plants in every row and column.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if case .tree = self[r, c] { n1 += 1 }
            }
            // 3. The numbers on the borders tell you how many Trees there are on that row.
            row2state[r] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
        }
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if case .tree = self[r, c] { n1 += 1 }
            }
            // 3. The numbers on the borders tell you how many Trees there are on that column.
            col2state[c] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] { self[r, c] = .empty }
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasArrow() -> Bool {
                    var n = 0
                    for i in 0..<8 {
                        let os = BotanicalParkGame.offset2[i]
                        var p2 = p + os
                        while isValid(p: p2) {
                            if case .arrow = self[p2], (game.pos2arrow[p2]! + 4) % 8 == i { n += 1 }
                            p2 += os
                        }
                    }
                    return game.onlyOneArrow && n == 1 || n >= 1
                }
                func hasTree() -> Bool {
                    var n = 0
                    let os = BotanicalParkGame.offset2[game.pos2arrow[p]!]
                    var p2 = p + os
                    while isValid(p: p2) {
                        if case .tree = self[p2] { n += 1 }
                        p2 += os
                    }
                    return game.onlyOneArrow && n == 1 || n >= 1
                }
                switch self[p] {
                case .tree:
                    // 2. Each tree is pointed at by at least one Arrow.
                    let s: AllowedObjectState = hasArrow() ? .normal : .error
                    self[p] = .tree(state: s)
                    if s == .error { isSolved = false }
                case .arrow:
                    // 2. Each Arrow points to at least one tree.
                    let s: AllowedObjectState = hasTree() ? .normal : .error
                    self[p] = .arrow(state: s)
                    if s == .error { isSolved = false }
                case .empty, .marker:
                    guard allowedObjectsOnly else {break}
                    if col2state[c] != .normal || row2state[r] != .normal || !hasArrow() { self[p] = .forbidden }
                default:
                    break
                }
            }
        }
    }
}
