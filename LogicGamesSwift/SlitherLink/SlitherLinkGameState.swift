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
        let p = move.p
        
        func adjustLightness(tolighten: Bool) {
            let f = { lightness in
                tolighten ? lightness + 1 : lightness > 0 ? lightness - 1 : lightness;
            }
            
            self[p].lightness = f(self[p].lightness)
            for os in SlitherLinkGame.offset {
                var p2 = p + os
                while isValid(p: p2) {
                    if case .wall = self[p2].objType {
                        break
                    } else {
                        self[p2].lightness = f(self[p2].lightness)
                    }
                    p2 += os
                }
            }
            updateIsSolved()
        }
        
        func objChanged() {
            changed = true
            self[p].objType = move.objType
        }
        
        switch (self[p].objType, move.objType) {
        case (_, .wall):
            self[p] = SlitherLinkObject(objType: move.objType, lightness: 0)
        case (.empty, .marker), (.marker, .empty):
            objChanged()
        case (.empty, .lightbulb), (.marker, .lightbulb):
            if options.normalLightbulbsOnly && self[p].lightness > 0 {break}
            objChanged()
            adjustLightness(tolighten: true)
        case (.lightbulb, .empty), (.lightbulb, .marker):
            objChanged()
            adjustLightness(tolighten: false)
        default:
            break
        }
        
        return changed
    }
    
    mutating func switchObject(move: inout SlitherLinkGameMove) -> Bool {
        let markerOption = SlitherLinkMarkerOptions(rawValue: options.markerOption)
        func f(o: SlitherLinkObjectType) -> SlitherLinkObjectType {
            switch o {
            case .empty:
                return markerOption == .markerBeforeLightbulb ? .marker : .lightbulb(state: .normal)
            case .lightbulb:
                return markerOption == .markerAfterLightbulb ? .marker : .empty
            case .marker:
                return markerOption == .markerBeforeLightbulb ? .lightbulb(state: .normal) : .empty
            case .wall:
                return o
            }
        }
        let p = move.p
        let o = f(o: self[p].objType)
        switch o {
        case .empty, .marker:
            move.objType = o
            return setObject(move: &move)
        case .lightbulb:
            move.objType = options.normalLightbulbsOnly && self[p].lightness > 0 ? f(o: o) : o
            return setObject(move: &move)
        case .wall:
            return false
        }
    }
    
    private(set) var isSolved = false
    
    private mutating func updateIsSolved() {
        isSolved = true
        for r in 0 ..< rows {
            for c in 0 ..< cols {
                let p = Position(r, c)
                let o = self[r, c]
                switch o.objType {
                case .empty where o.lightness == 0, .marker where o.lightness == 0:
                    isSolved = false
                case .lightbulb:
                    let state: SlitherLinkLightbulbState = o.lightness == 1 ? .normal : .error
                    self[r, c].objType = .lightbulb(state: state)
                    if o.lightness > 1 {isSolved = false}
                case .wall:
                    let lightbulbs = game.wall2Lightbulbs[p]!
                    guard lightbulbs >= 0 else {break}
                    var n = 0
                    for os in SlitherLinkGame.offset {
                        let p2 = p + os
                        guard isValid(p: p2) else {continue}
                        if case .lightbulb = self[p2].objType {
                            n += 1
                        }
                    }
                    let state: SlitherLinkWallState = n < lightbulbs ? .normal : n == lightbulbs ? .complete : .error
                    self[r, c].objType = .wall(state: state)
                    if n != lightbulbs {isSolved = false}
                default:
                    break
                }
            }
        }
    }
}
