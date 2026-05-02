//
//  ADifferentFarmerGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ADifferentFarmerGameState: GridGameState<ADifferentFarmerGameMove> {
    var game: ADifferentFarmerGame {
        get { getGame() as! ADifferentFarmerGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ADifferentFarmerDocument.sharedInstance }
    var objArray = [ADifferentFarmerObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> ADifferentFarmerGameState {
        let v = ADifferentFarmerGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ADifferentFarmerGameState) -> ADifferentFarmerGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ADifferentFarmerGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> ADifferentFarmerObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ADifferentFarmerObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ADifferentFarmerGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ADifferentFarmerGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: .up
        case .up: .right
        case .right: .down
        case .down: .left
        case .left: .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 4/A different Farmer

        Summary
        Not all farmers are created equal

        Description
        1. A Different Farmer plants fruits and vegetables in a different way.
        2. He places exactly one of each of the three fruits or vegetables in each field
           (marked area).
        3. The same plant cannot be placed in adjacent tiles, not even diagonally.
        4. All the plants must be connected horizontally or vertically.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 3. Arrows in an area should all be different, i.e. there can't be two
        //    similar arrows in an area.
        for area in game.areas {
            var symbol2range = [ADifferentFarmerObject: [Position]]()
            for p in area { symbol2range[self[p], default: []].append(p) }
            for (_, range) in symbol2range where range.count > 1 {
                isSolved = false
                for p in range { pos2state[p] = .error }
            }
            if symbol2range.keys.contains(ADifferentFarmerObject.empty) { isSolved = false }
        }
        guard isSolved else {return}
        // 1. All the roads lead to ADifferentFarmer.
        // 2. Hence you should fill the remaining spaces with arrows and in the
        //    end, starting at any tile and following the arrows, you should get
        //    at the ADifferentFarmer icon.
        var validRange = Set<Position>()
        var invalidRange = Set<Position>()
        for r in 0..<rows {
            for c in 0..<cols {
                var p = Position(r, c)
                var range = Set<Position>()
                while true {
                    let o = self[p]
                    if o == .rome || validRange.contains(p) {
                        for p2 in range { validRange.insert(p2) }
                        break
                    }
                    if !isValid(p: p) || invalidRange.contains(p) || range.contains(p) {
                        isSolved = false
                        for p2 in range { invalidRange.insert(p2) }
                        break
                    }
                    range.insert(p)
                    let os = ADifferentFarmerGame.offset[o.rawValue - 2]
                    p += os
                }
            }
        }
        for p in invalidRange { pos2state[p] = .error }
    }
}
