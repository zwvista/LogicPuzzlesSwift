//
//  GemsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GemsGameState: GridGameState<GemsGameMove> {
    var game: GemsGame {
        get { getGame() as! GemsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { GemsDocument.sharedInstance }
    var objArray = [GemsObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> GemsGameState {
        let v = GemsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: GemsGameState) -> GemsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: GemsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<GemsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> GemsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GemsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout GemsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout GemsGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GemsObject) -> GemsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .gem
            case .gem:
                return .pebble
            case .pebble:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .gem : .empty
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
        iOS Game: 100 Logic Games 2/Puzzle Set 1/Gems

        Summary
        Gemscraper

        Description
        1. The board contains one Sapphire (Blue Gem) on each row and column.
        2. There are also a random amount of Pebbles (in White) on the board.
        3. A number on the border tells you how many stones you can see from
           there, up to and including the Sapphire.
        4. The Sapphire (blue) hide the Pebbles (white) behind them.
    */
    private func updateIsSolved() {
        isSolved = true
        func f(_ r: Int, _ c: Int) -> Bool {
            let o = self[r, c]
            return o == .gem || o == .pebble
        }
        for r in 1..<rows - 1 {
            let (p1, p2) = (Position(r, 0), Position(r, cols - 1))
            let (h1, h2) = (game.pos2hint[p1]!, game.pos2hint[p2]!)
            let gems = (1..<cols - 1).map { Position(r, $0) }.filter { self[$0] == .gem }
            if gems.count == 1 {
                // 1. The board contains one Sapphire (Blue Gem) on each row and column.
                let p = gems.first!, c = p.col
                pos2state[p] = .normal
                // 2. There are also a random amount of Pebbles (in White) on the board.
                // 3. A number on the border tells you how many stones you can see from
                //    there, up to and including the Sapphire.
                // 4. The Sapphire (blue) hide the Pebbles (white) behind them.
                let (n1, n2) = ((1...c).count { f(r, $0) }, (c..<cols - 1).count { f(r, $0) })
                let s1: HintState = n1 < h1 ? .normal : n1 == h1 ? .complete : .error
                let s2: HintState = n2 < h2 ? .normal : n2 == h2 ? .complete : .error
                pos2state[p1] = s1; pos2state[p2] = s2
                if s1 != .complete || s2 != .complete { isSolved = false }
            } else {
                isSolved = false
                gems.forEach { pos2state[$0] = .error }
            }
        }
        for c in 1..<cols - 1 {
            let (p1, p2) = (Position(0, c), Position(rows - 1, c))
            let (h1, h2) = (game.pos2hint[p1]!, game.pos2hint[p2]!)
            let gems = (1..<rows - 1).map { Position($0, c) }.filter { self[$0] == .gem }
            if gems.count == 1 {
                // 1. The board contains one Sapphire (Blue Gem) on each row and column.
                let p = gems.first!, r = p.row
                pos2state[p] = .normal
                // 2. There are also a random amount of Pebbles (in White) on the board.
                // 3. A number on the border tells you how many stones you can see from
                //    there, up to and including the Sapphire.
                // 4. The Sapphire (blue) hide the Pebbles (white) behind them.
                let (n1, n2) = ((1...r).count { f($0, c) }, (r..<rows - 1).count { f($0, c) })
                let s1: HintState = n1 < h1 ? .normal : n1 == h1 ? .complete : .error
                let s2: HintState = n2 < h2 ? .normal : n2 == h2 ? .complete : .error
                pos2state[p1] = s1; pos2state[p2] = s2
                if s1 != .complete || s2 != .complete { isSolved = false }
            } else {
                isSolved = false
                gems.forEach { pos2state[$0] = .error }
            }
        }
    }
}
