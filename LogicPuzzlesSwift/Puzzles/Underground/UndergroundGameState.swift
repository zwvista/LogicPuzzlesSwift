//
//  UndergroundGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class UndergroundGameState: GridGameState<UndergroundGameMove> {
    var game: UndergroundGame {
        get { getGame() as! UndergroundGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { UndergroundDocument.sharedInstance }
    var objArray = [UndergroundObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> UndergroundGameState {
        let v = UndergroundGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: UndergroundGameState) -> UndergroundGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: UndergroundGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> UndergroundObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> UndergroundObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout UndergroundGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout UndergroundGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
       func f(o: UndergroundObject) -> UndergroundObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .balloon
            case .balloon:
                return .weight
            case .weight:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .balloon : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p), self[p] != .block else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Underground

        Summary
        Subway entrances

        Description
        1. Each neighbourhood contains one entrance to the Underground.
        2. For each entrance there is a corresponding entrance in a different neighbourhood.
        3. The arrows of two corresponding entrances must point to each other.
        4. Between two corresponding entrances there cannot be any other entrance.
        5. Two corresponding entrances cannot be in adjacent neighbourhood, i.e.
           there must be at least one neighbourhood between them.
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
            var symbol2range = [UndergroundObject: [Position]]()
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
