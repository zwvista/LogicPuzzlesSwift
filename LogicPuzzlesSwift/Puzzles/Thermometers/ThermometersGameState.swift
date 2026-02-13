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
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .filled()
        case .filled: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .filled() : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 14/Thermometers

        Summary
        Puzzle Fever

        Description
        1. On the board a few Thermometers are laid down. Your goal is  to fill
           them according to the hints.
        2. In a Thermometer, mercury always starts at the bulb and can progressively
           fill the Thermometer towards the end.
        3. A Thermometer can also be completely empty, including the bulb.
        4. The numbers on the border tell you how many filled cells are present
           on that Row or Column.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        // 2. In a Thermometer, mercury always starts at the bulb and can progressively
        // fill the Thermometer towards the end.
        for thermometer in game.thermometers {
            var canbeFilled = true
            for p in thermometer {
                if case .filled = self[p] {
                    let s: AllowedObjectState = canbeFilled ? .normal : .error
                    if s == .error { isSolved = false }
                    self[p] = .filled(state: s)
                } else {
                    if allowedObjectsOnly && !canbeFilled {
                        self[p] = .forbidden
                    } else if case .forbidden = self[p] {
                        self[p] = .empty
                    }
                    canbeFilled = false
                }
            }
        }
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if case .filled = self[r, c] { n1 += 1 }
            }
            // 4. The numbers on the border tell you how many filled cells are present
            // on that Row.
            row2state[r] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
            if n1 == n2 && allowedObjectsOnly {
                for c in 0..<cols {
                    if case .filled = self[r, c] {
                    } else {
                        self[r, c] = .forbidden
                    }
                }
            }
        }
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if case .filled = self[r, c] { n1 += 1 }
            }
            // 4. The numbers on the border tell you how many filled cells are present
            // on that Column.
            col2state[c] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
            if n1 == n2 && allowedObjectsOnly {
                for r in 0..<rows {
                    if case .filled = self[r, c] {
                    } else {
                        self[r, c] = .forbidden
                    }
                }
            }
        }
    }
}
