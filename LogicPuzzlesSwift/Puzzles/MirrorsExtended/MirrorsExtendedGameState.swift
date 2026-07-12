//
//  MirrorsExtendedGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import OrderedCollections

class MirrorsExtendedGameState: GridGameState<MirrorsExtendedGameMove> {
    var game: MirrorsExtendedGame {
        get { getGame() as! MirrorsExtendedGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MirrorsExtendedDocument.sharedInstance }
    var objArray = [MirrorsExtendedObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> MirrorsExtendedGameState {
        let v = MirrorsExtendedGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MirrorsExtendedGameState) -> MirrorsExtendedGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: MirrorsExtendedGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MirrorsExtendedObject>(repeating: MirrorsExtendedObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MirrorsExtendedObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MirrorsExtendedObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MirrorsExtendedGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout MirrorsExtendedGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .water
        case .water: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .water : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 4/Mirrors, extended

        Summary
        with lasers, of course

        Description
        1. On the border there are some lasers, marked with the letter and number.
        2. The letter tells you where that laser beam will start and end (it is paired with the same
           letter somewhere else).
        3. The number tells you how many mirrors the laser beam will bounce off before reaching the
           other letter.
        4. Each area contains one mirror.
        5. Each mirror reflects at least one laser beam.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .forbidden { self[p] = .empty }
                pos2state[p] = .normal
            }
        }
        // 2. You have to fill some water in it, considering that water pours down
        //    and levels itself like in reality.
        // 3. Areas of the same level which are horizontally connected will have
        //    the same water level.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] == .water else {continue}
                if !([1, 2, 3].allSatisfy { i in
                    game.dots[p + MirrorsExtendedGame.offset2[i]][MirrorsExtendedGame.dirs[i]] == .line ||
                    self[p + MirrorsExtendedGame.offset[i]] == .water
                }) { pos2state[p] = .error; isSolved = false }
            }
        }
        // 4. The numbers on the border show you how many tiles of each row and
        //    column are filled.
        for r in 0..<rows {
            let n2 = game.row2hint[r]
            guard n2 != MirrorsExtendedGame.PUZ_UNKNOWN else {continue}
            let n1 = (0..<cols).count { self[r, $0] == .water }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
            guard s != .normal && allowedObjectsOnly else {continue}
            (0..<cols).filter { self[r, $0] == .empty }.forEach {
                self[r, $0] = .forbidden
            }
        }
        for c in 0..<cols {
            let n2 = game.col2hint[c]
            guard n2 != MirrorsExtendedGame.PUZ_UNKNOWN else {continue}
            let n1 = (0..<rows).count { self[$0, c] == .water }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
            guard s != .normal && allowedObjectsOnly else {continue}
            (0..<rows).filter { self[$0, c] == .empty }.forEach {
                self[$0, c] = .forbidden
            }
        }
    }
}
