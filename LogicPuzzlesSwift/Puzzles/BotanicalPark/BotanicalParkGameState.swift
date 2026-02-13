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
    
    override func copy() -> BotanicalParkGameState {
        let v = BotanicalParkGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BotanicalParkGameState) -> BotanicalParkGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: BotanicalParkGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BotanicalParkObject>(repeating: BotanicalParkObject(), count: rows * cols)
        for (p, _) in game.pos2arrow {
            self[p] = .arrow()
        }
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
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .plant()
        case .plant: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .plant() : .empty
        default: o
        }
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
            for c in 0..<cols {
                if case .forbidden = self[r, c] { self[r, c] = .empty }
            }
        }
        // 3. Plants cannot touch, not even diagonally.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor() -> Bool {
                    for os in BotanicalParkGame.offset {
                        let p2 = p + os
                        if isValid(p: p2), case .plant = self[p2] { return true }
                    }
                    return false
                }
                switch self[p] {
                case .plant:
                    let s: AllowedObjectState = !hasNeighbor() ? .normal : .error
                    self[p] = .plant(state: s)
                    if s == .error { isSolved = false }
                case .empty, .marker:
                    if allowedObjectsOnly && hasNeighbor() { self[p] = .forbidden }
                default:
                    break
                }
            }
        }
        let n2 = game.plantsInEachArea
        // 2. There is exactly one plant in every row.
        for r in 0..<rows {
            var n1 = 0
            for c in 0..<cols {
                if case .plant = self[r, c] { n1 += 1 }
            }
            if n1 != n2 { isSolved = false }
            for c in 0..<cols {
                switch self[r, c] {
                case let .plant(state):
                    self[r, c] = .plant(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .empty, .marker:
                    if n1 >= n2 && allowedObjectsOnly { self[r, c] = .forbidden }
                default:
                    break
                }
            }
        }
        // 2. There is exactly one plant in every column.
        for c in 0..<cols {
            var n1 = 0
            for r in 0..<rows {
                if case .plant = self[r, c] { n1 += 1 }
            }
            if n1 != n2 { isSolved = false }
            for r in 0..<rows {
                switch self[r, c] {
                case let .plant(state):
                    self[r, c] = .plant(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .empty, .marker:
                    if n1 >= n2 && allowedObjectsOnly { self[r, c] = .forbidden }
                default:
                    break
                }
            }
        }
        // 2. Each arrow points to at least one plant.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasPlant() -> Bool {
                    var n = 0
                    let os = BotanicalParkGame.offset[game.pos2arrow[p]!]
                    var p2 = p + os
                    while isValid(p: p2) {
                        if case .plant = self[p2] { n += 1 }
                        p2 += os
                    }
                    return n >= 1
                }
                if case .arrow = self[p] {
                    // 2. Each Arrow points to at least one plant.
                    let s: AllowedObjectState = hasPlant() ? .normal : .error
                    self[p] = .arrow(state: s)
                    if s == .error { isSolved = false }
                }
            }
        }
    }
}
