//
//  HeliumAndIronGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HeliumAndIronGameState: GridGameState<HeliumAndIronGameMove> {
    var game: HeliumAndIronGame {
        get { getGame() as! HeliumAndIronGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { HeliumAndIronDocument.sharedInstance }
    var objArray = [HeliumAndIronObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> HeliumAndIronGameState {
        let v = HeliumAndIronGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: HeliumAndIronGameState) -> HeliumAndIronGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: HeliumAndIronGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> HeliumAndIronObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> HeliumAndIronObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout HeliumAndIronGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout HeliumAndIronGameMove) -> GameOperationType {
        func f(o: HeliumAndIronObject) -> HeliumAndIronObject {
            switch o {
            case .empty:
                return .up
            case .up:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 2/HeliumAndIron

        Summary
        All roads lead to ...

        Description
        1. All the roads lead to HeliumAndIron.
        2. Hence you should fill the remaining spaces with arrows and in the
           end, starting at any tile and following the arrows, you should get
           at the HeliumAndIron icon.
        3. Arrows in an area should all be different, i.e. there can't be two
           similar arrows in an area.
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
            var symbol2range = [HeliumAndIronObject: [Position]]()
            for p in area { symbol2range[self[p], default: []].append(p) }
            for (_, range) in symbol2range where range.count > 1 {
                for p in range { isSolved = false; pos2state[p] = .error }
            }
            if symbol2range.keys.contains(HeliumAndIronObject.empty) { isSolved = false }
        }
        guard isSolved else {return}
        // 1. All the roads lead to HeliumAndIron.
        // 2. Hence you should fill the remaining spaces with arrows and in the
        //    end, starting at any tile and following the arrows, you should get
        //    at the HeliumAndIron icon.
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
                    let os = HeliumAndIronGame.offset[o.rawValue - 2]
                    p += os
                }
            }
        }
        for p in invalidRange { pos2state[p] = .error }
    }
}
