//
//  SlitherLinkGameState.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct SlitherLinkGameState {
    let game: SlitherLinkGame
    var size: Position { return game.size }
    var rows: Int { return size.row }
    var cols: Int { return size.col }    
    func isValid(p: Position) -> Bool {
        return game.isValid(p: p)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return game.isValid(row: row, col: col)
    }
    var objArray = [SlitherLinkObject]()
    var pos2state = [Position: SlitherLinkHintState]()
    var options: SlitherLinkGameProgress { return SlitherLinkDocument.sharedInstance.gameProgress }
    
    init(game: SlitherLinkGame) {
        self.game = game
        objArray = Array<SlitherLinkObject>(repeating: SlitherLinkObject(), count: rows * cols)
    }
    
    subscript(p: Position) -> SlitherLinkObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> SlitherLinkObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    mutating func setObject(move: inout SlitherLinkGameMove) -> Bool {
        var changed = false
        func f(objType: inout SlitherLinkObjectType) {
            if objType != move.objType {
                changed = true
                objType = move.objType
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let p = move.p
        switch move.objOrientation {
        case .horizontal:
            f(objType: &self[p].objTypeHorz)
            if changed {updateIsSolved()}
        case .vertical:
            f(objType: &self[p].objTypeVert)
            if changed {updateIsSolved()}
        }
        return changed
    }
    
    mutating func switchObject(move: inout SlitherLinkGameMove) -> Bool {
        let markerOption = SlitherLinkMarkerOptions(rawValue: options.markerOption)
        func f(o: SlitherLinkObjectType) -> SlitherLinkObjectType {
            switch o {
            case .empty:
                return markerOption == .markerBeforeLine ? .marker : .line
            case .line:
                return markerOption == .markerAfterLine ? .marker : .empty
            case .marker:
                return markerOption == .markerBeforeLine ? .line : .empty
            }
        }
        let p = move.p
        let o = f(o: move.objOrientation == .horizontal ? self[p].objTypeHorz : self[p].objTypeVert)
        move.objType = o
        return setObject(move: &move)
    }
    
    private(set) var isSolved = false
    
    private mutating func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2hint {
            var n1 = 0
            if self[p].objTypeHorz == .line {n1 += 1}
            if self[p].objTypeVert == .line {n1 += 1}
            if self[p + SlitherLinkGame.offset[2]].objTypeHorz == .line {n1 += 1}
            if self[p + SlitherLinkGame.offset[1]].objTypeVert == .line {n1 += 1}
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        isSolved = false
    }
}
