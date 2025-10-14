//
//  BootyIslandGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BootyIslandGameState: GridGameState<BootyIslandGameMove> {
    var game: BootyIslandGame {
        get { getGame() as! BootyIslandGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { BootyIslandDocument.sharedInstance }
    var objArray = [BootyIslandObject]()
    
    override func copy() -> BootyIslandGameState {
        let v = BootyIslandGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BootyIslandGameState) -> BootyIslandGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: BootyIslandGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BootyIslandObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> BootyIslandObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> BootyIslandObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout BootyIslandGameMove) -> GameOperationType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return .invalid }
        guard String(describing: o1) != String(describing: o2) else { return .invalid }
        self[p] = o2
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout BootyIslandGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: BootyIslandObject) -> BootyIslandObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .treasure(state: .normal)
            case .treasure:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .treasure(state: .normal) : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 13/Booty Island

        Summary
        Overcrowded Piracy

        Description
        1. Overcrowded by Greedy Pirates (tm), this land has Treasures buried
           almost everywhere and the relative maps scattered around.
        2. In fact there's only one Treasure for each row and for each column.
        3. On the island you can see maps with a number: these tell you how
           many steps are required, horizontally or vertically, to reach a
           Treasure.
        4. For how stupid the Pirates are, they don't bury their Treasures
           touching each other, even diagonally, however at times they are so
           stupid that two or more maps point to the same Treasure!

        Bigger Islands
        5. On bigger islands, there will be two Treasures per row and column.
        6. In this case, the number on the map doesn't necessarily point to the
           closest Treasure on that row or column.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .treasure:
                    self[p] = .treasure(state: .normal)
                default:
                    break
                }
            }
        }
        // 4. Pirates don't bury their Treasures touching each other, even diagonally.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor() -> Bool {
                    for os in BootyIslandGame.offset {
                        let p2 = p + os
                        if isValid(p: p2), case .treasure = self[p2] { return true }
                    }
                    return false
                }
                switch self[p] {
                case let .treasure(state):
                    let s: AllowedObjectState = state == .normal && !hasNeighbor() ? .normal : .error
                    self[p] = .treasure(state: s)
                    if s == .error { isSolved = false }
                case .empty, .marker:
                    if allowedObjectsOnly && hasNeighbor() { self[p] = .forbidden }
                default:
                    break
                }
            }
        }
        let n2 = 1
        // 2. In fact there's only one Treasure for each row.
        for r in 0..<rows {
            var n1 = 0
            for c in 0..<cols {
                if case .treasure = self[r, c] { n1 += 1 }
            }
            if n1 != n2 { isSolved = false }
            for c in 0..<cols {
                switch self[r, c] {
                case let .treasure(state):
                    self[r, c] = .treasure(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .empty, .marker:
                    if n1 == n2 && allowedObjectsOnly { self[r, c] = .forbidden }
                default:
                    break
                }
            }
        }
        // 2. In fact there's only one Treasure for each column.
        for c in 0..<cols {
            var n1 = 0
            for r in 0..<rows {
                if case .treasure = self[r, c] { n1 += 1 }
            }
            if n1 != n2 { isSolved = false }
            for r in 0..<rows {
                switch self[r, c] {
                case let .treasure(state):
                    self[r, c] = .treasure(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .empty, .marker:
                    if n1 == n2 && allowedObjectsOnly { self[r, c] = .forbidden }
                default:
                    break
                }
            }
        }
        // 3. On the island you can see maps with a number: these tell you how
        // many steps are required, horizontally or vertically, to reach a
        // Treasure.
        for (p, n2) in game.pos2hint {
            func f() -> HintState {
                var possible = false
                next: for i in 0..<4 {
                    let os = BootyIslandGame.offset[i * 2]
                    var n1 = 1, p2 = p + os
                    var possible2 = false
                    while isValid(p: p2) {
                        switch self[p2] {
                        case .treasure:
                            if n1 == n2 { return .complete }
                            continue next
                        case .empty:
                            if n1 == n2 { possible2 = true }
                        default:
                            if n1 == n2 { continue next }
                        }
                        n1 += 1; p2 += os
                    }
                    if possible2 { possible = true }
                }
                return possible ? .normal : .error
            }
            let s = f()
            self[p] = .hint(state: s)
            if s != .complete { isSolved = false }
        }
    }
}
