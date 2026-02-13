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
        let p = move.p
        guard isValid(p: p), self[p] != .block else { return .invalid }
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .balloon
        case .balloon: .weight
        case .weight: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .balloon : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 2/Helium And Iron

        Summary
        One rises, the other falls

        Description
        1. Place a Balloon and a Weight in each Area.
        2. Helium Balloons ten to float to the top, while Iron Weight tend to fall
           to the ground.
        3. A Balloon can be placed on the top of the board, under another Balloon,
           or under a Block.
        4. A Weight can be placed on the bottom of the board, over another Weight,
           or over a Block.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 1. Place a Balloon and a Weight in each Area.
        for area in game.areas where area.count > 1 {
            var symbol2range = [HeliumAndIronObject: [Position]]()
            symbol2range[.balloon] = []
            symbol2range[.weight] = []
            for p in area {
                let o = self[p]
                guard o == .balloon || o == .weight else {continue}
                symbol2range[o]!.append(p)
            }
            for (_, range) in symbol2range where range.count != 1 {
                isSolved = false
                for p in range { pos2state[p] = .error }
            }
        }
        guard isSolved else {return}
        // 2. Helium Balloons ten to float to the top, while Iron Weight tend to fall
        //    to the ground.
        for c in 0..<cols {
            for r in 0..<rows {
                let p = Position(r, c)
                let o = self[p]
                if o == .balloon {
                    // 3. A Balloon can be placed on the top of the board, under another Balloon,
                    //    or under a Block.
                    if !(r == 0 || self[r - 1, c] == .balloon || self[r - 1, c] == .block) {
                        isSolved = false
                        pos2state[p] = .error
                    }
                } else if o == .weight {
                    // 4. A Weight can be placed on the bottom of the board, over another Weight,
                    //    or over a Block.
                    if !(r == rows - 1 || self[r + 1, c] == .weight || self[r - 1, c] == .block) {
                        isSolved = false
                        pos2state[p] = .error
                    }
                }
            }
        }
    }
}
