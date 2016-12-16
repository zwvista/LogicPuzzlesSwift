//
//  ParksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ParksGameState: CellsGameState, ParksMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: ParksGame {
        get {return getGame() as! ParksGame}
        set {setGame(game: newValue)}
    }
    var objArray = [ParksObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ParksGameState {
        let v = ParksGameState(game: game)
        return setup(v: v)
    }
    func setup(v: ParksGameState) -> ParksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: ParksGame) {
        super.init(game: game);
        objArray = Array<ParksObject>(repeating: .empty, count: rows * cols)
    }
    
    subscript(p: Position) -> ParksObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> ParksObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout ParksGameMove) -> Bool {
        var changed = false
        let p = move.p
        
        func objChanged() {
            changed = true
            self[p] = move.obj
        }
        
        switch (self[p], move.obj) {
        case (.empty, .marker), (.marker, .empty):
            objChanged()
        case (.empty, .tree), (.marker, .tree):
            if allowedObjectsOnly {break}
            objChanged()
        case (.tree, .empty), (.tree, .marker):
            objChanged()
        default:
            break
        }
        
        return changed
    }
    
    func switchObject(move: inout ParksGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: ParksObject) -> ParksObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tree(state: .normal)
            case .tree:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tree(state: .normal) : .empty
            }
        }
        let o = f(o: self[move.p])
        switch o {
        case .empty, .marker:
            move.obj = o
            return setObject(move: &move)
        case .tree:
            move.obj = allowedObjectsOnly ? f(o: o) : o
            return setObject(move: &move)
        }
    }
    
    private func updateIsSolved() {
        isSolved = true
    }
}
