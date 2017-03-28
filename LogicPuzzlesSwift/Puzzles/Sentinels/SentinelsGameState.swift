//
//  SentinelsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SentinelsGameState: GridGameState, SentinelsMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: SentinelsGame {
        get {return getGame() as! SentinelsGame}
        set {setGame(game: newValue)}
    }
    var objArray = [SentinelsObject]()
    
    override func copy() -> SentinelsGameState {
        let v = SentinelsGameState(game: game)
        return setup(v: v)
    }
    func setup(v: SentinelsGameState) -> SentinelsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SentinelsGame) {
        super.init(game: game)
        objArray = Array<SentinelsObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
    }
    
    subscript(p: Position) -> SentinelsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> SentinelsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout SentinelsGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 {return false}
        // guard case .hint != o1 else {return false} // syntax error
        // guard !(.hint ~= o1) else {return false} // syntax error
        guard String(describing: o1) != String(describing: o2) else {return false}
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout SentinelsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: SentinelsObject) -> SentinelsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .sentinel
            case .sentinel:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .sentinel : .empty
            case .hint:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2hint {
            var n1 = 1
            for os in SentinelsGame.offset {
                var p2 = p + os
                while game.isValid(p: p2) {
                    if case .sentinel = self[p2] {break}
                    n1 += 1
                    p2 += os
                }
            }
            let s: HintState = n1 > n2 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {isSolved = false}
        }
    }
}
