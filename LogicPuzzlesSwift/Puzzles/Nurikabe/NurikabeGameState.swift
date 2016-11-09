//
//  NurikabeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NurikabeGameState: CellsGameState {
    var game: NurikabeGame {return gameBase as! NurikabeGame}
    var objArray = [NurikabeObject]()
    var options: NurikabeGameProgress { return NurikabeDocument.sharedInstance.gameProgress }
    
    override func copy() -> NurikabeGameState {
        let v = NurikabeGameState(game: gameBase)
        return setup(v: v)
    }
    func setup(v: NurikabeGameState) -> NurikabeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CellsGameBase) {
        super.init(game: game)
        objArray = Array<NurikabeObject>(repeating: NurikabeObject(), count: rows * cols)
    }
    
    subscript(p: Position) -> NurikabeObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> NurikabeObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout NurikabeGameMove) -> Bool {
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
    
    func switchObject(move: inout NurikabeGameMove) -> Bool {
        let markerOption = NurikabeMarkerOptions(rawValue: options.markerOption)
        func f(o: NurikabeObject) -> NurikabeObject {
            switch o {
            case .empty:
                return markerOption == .markerBeforeWall ? .marker : .wall
            case .wall:
                return markerOption == .markerAfterWall ? .marker : .empty
            case .marker:
                return markerOption == .markerBeforeWall ? .wall : .empty
            case .hint:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        isSolved = false
    }
}
