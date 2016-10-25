//
//  CloudsGameState.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct CloudsGameState {
    let game: CloudsGame
    var size: Position { return game.size }
    var rows: Int { return size.row }
    var cols: Int { return size.col }    
    func isValid(p: Position) -> Bool {
        return game.isValid(p: p)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return game.isValid(row: row, col: col)
    }
    var objArray = [CloudsObject]()
    var row2state = [CloudsHintState]()
    var col2state = [CloudsHintState]()
    var options: CloudsGameProgress { return CloudsDocument.sharedInstance.gameProgress }
    
    init(game: CloudsGame) {
        self.game = game
        objArray = Array<CloudsObject>(repeating: CloudsObject(), count: rows * cols)
    }
    
    subscript(p: Position) -> CloudsObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> CloudsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    mutating func setObject(move: inout CloudsGameMove) -> Bool {
        var changed = false
        let p = move.p
        if self[p] != move.obj {
            changed = true
            self[p] = move.obj
            updateIsSolved()
        }
        return changed
    }
    
    mutating func switchObject(move: inout CloudsGameMove) -> Bool {
        let markerOption = CloudsMarkerOptions(rawValue: options.markerOption)
        func f(o: CloudsObject) -> CloudsObject {
            switch o {
            case .empty:
                return markerOption == .markerBeforeCloud ? .marker : .cloud
            case .cloud:
                return markerOption == .markerAfterCloud ? .marker : .empty
            case .marker:
                return markerOption == .markerBeforeCloud ? .cloud : .empty
            }
        }
        let p = move.p
        let o = f(o: self[p])
        move.obj = o
        return setObject(move: &move)
    }
    
    private(set) var isSolved = false
    
    private mutating func updateIsSolved() {
        isSolved = true
    }
}
