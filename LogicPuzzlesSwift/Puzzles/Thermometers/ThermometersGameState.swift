//
//  ThermometersGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ThermometersGameState: GridGameState<ThermometersGameMove> {
    var game: ThermometersGame {
        get { getGame() as! ThermometersGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ThermometersDocument.sharedInstance }
    var objArray = [ThermometersObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> ThermometersGameState {
        let v = ThermometersGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ThermometersGameState) -> ThermometersGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: ThermometersGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ThermometersObject>(repeating: ThermometersObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> ThermometersObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ThermometersObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ThermometersGameMove) -> GameOperationType {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ThermometersGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: ThermometersObject) -> ThermometersObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .filled
            case .filled:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .filled : .empty
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
        iOS Game: 100 Logic Games/Puzzle Set 2/Hidden Stars

        Summary
        Each Arrow points to a Star and every Star has an arrow pointing at it

        Description
        1. In the board you have to find hidden stars.
        2. Each star is pointed at by at least one Arrow and each Arrow points
           to at least one star.
        3. The number on the borders tell you how many Stars there on that row
           or column.

        Variant
        4. Some levels have a variation of these rules: Stars must be pointed
           by one and only one Arrow.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
//        isSolved = true
//        for r in 0..<rows {
//            var n1 = 0
//            let n2 = game.row2hint[r]
//            for c in 0..<cols {
//                if case .star = self[r, c] { n1 += 1 }
//            }
//            // 3. The numbers on the borders tell you how many Stars there are on that row.
//            row2state[r] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
//            if n1 != n2 { isSolved = false }
//        }
//        for c in 0..<cols {
//            var n1 = 0
//            let n2 = game.col2hint[c]
//            for r in 0..<rows {
//                if case .star = self[r, c] { n1 += 1 }
//            }
//            // 3. The numbers on the borders tell you how many Stars there are on that column.
//            col2state[c] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
//            if n1 != n2 { isSolved = false }
//        }
//        for r in 0..<rows {
//            for c in 0..<cols {
//                if case .forbidden = self[r, c] { self[r, c] = .empty }
//            }
//        }
//        for r in 0..<rows {
//            for c in 0..<cols {
//                let p = Position(r, c)
//                func hasArrow() -> Bool {
//                    var n = 0
//                    for i in 0..<8 {
//                        let os = ThermometersGame.offset2[i]
//                        var p2 = p + os
//                        while isValid(p: p2) {
//                            if case .arrow = self[p2], (game.pos2arrow[p2]! + 4) % 8 == i { n += 1 }
//                            p2 += os
//                        }
//                    }
//                    return game.onlyOneArrow && n == 1 || n >= 1
//                }
//                func hasStar() -> Bool {
//                    var n = 0
//                    let os = ThermometersGame.offset2[game.pos2arrow[p]!]
//                    var p2 = p + os
//                    while isValid(p: p2) {
//                        if case .star = self[p2] { n += 1 }
//                        p2 += os
//                    }
//                    return game.onlyOneArrow && n == 1 || n >= 1
//                }
//                switch self[p] {
//                case .star:
//                    // 2. Each star is pointed at by at least one Arrow.
//                    let s: AllowedObjectState = hasArrow() ? .normal : .error
//                    self[p] = .star(state: s)
//                    if s == .error { isSolved = false }
//                case .arrow:
//                    // 2. Each Arrow points to at least one star.
//                    let s: AllowedObjectState = hasStar() ? .normal : .error
//                    self[p] = .arrow(state: s)
//                    if s == .error { isSolved = false }
//                case .empty, .marker:
//                    guard allowedObjectsOnly else {break}
//                    if col2state[c] != .normal || row2state[r] != .normal || !hasArrow() { self[p] = .forbidden }
//                default:
//                    break
//                }
//            }
//        }
    }
}
