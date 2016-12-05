//
//  MosaikGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MosaikGameState: CellsGameState, MosaikMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: MosaikGame {
        get {return getGame() as! MosaikGame}
        set {setGame(game: newValue)}
    }
    var objArray = [MosaikObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> MosaikGameState {
        let v = MosaikGameState(game: game)
        return setup(v: v)
    }
    func setup(v: MosaikGameState) -> MosaikGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: MosaikGame) {
        super.init(game: game);
        objArray = Array<MosaikObject>(repeating: .empty, count: rows * cols)
        for (p, n) in game.pos2hint {
            pos2state[p] = n == 0 ? .complete : .normal
        }
    }
    
    subscript(p: Position) -> MosaikObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> MosaikObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout MosaikGameMove) -> Bool {
        var changed = false
        func f(o1: inout MosaikObject, o2: inout MosaikObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        f(o1: &self[move.p], o2: &move.obj)
        if changed {updateIsSolved()}
        return changed
    }
    
    func switchObject(move: inout MosaikGameMove) -> Bool {
        let markerOption = MosaikMarkerOptions(rawValue: self.markerOption)
        func f(o: MosaikObject) -> MosaikObject {
            switch o {
            case .empty:
                return markerOption == .markerBeforeFill ? .marker : .filled
            case .filled:
                return markerOption == .markerAfterFill ? .marker : .empty
            case .marker:
                return markerOption == .markerBeforeFill ? .filled : .empty
            }
        }
        let o = f(o: self[move.p])
        move.obj = o
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2hint {
            var n1 = 0
            for os in MosaikGame.offset {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                if self[p2] == .filled {n1 += 1}
            }
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
    }
}
