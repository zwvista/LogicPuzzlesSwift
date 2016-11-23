//
//  LightenUpGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightenUpGameState: CellsGameState, LightenUpMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: LightenUpGame {
        get {return getGame() as! LightenUpGame}
        set {setGame(game: newValue)}
    }
    var objArray = [LightenUpObject]()
    
    override func copy() -> LightenUpGameState {
        let v = LightenUpGameState(game: game)
        return setup(v: v)
    }
    func setup(v: LightenUpGameState) -> LightenUpGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LightenUpGame) {
        super.init(game: game);
        objArray = Array<LightenUpObject>(repeating: LightenUpObject(), count: rows * cols)
        for (p, lightbulbs) in game.wall2Lightbulbs {
            self[p].objType = .wall(state: lightbulbs <= 0 ? .complete : .normal)
        }
    }
    
    subscript(p: Position) -> LightenUpObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> LightenUpObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout LightenUpGameMove) -> Bool {
        var changed = false
        let p = move.p
        
        func adjustLightness(tolighten: Bool) {
            let f = { lightness in
                tolighten ? lightness + 1 : lightness > 0 ? lightness - 1 : lightness;
            }
            
            self[p].lightness = f(self[p].lightness)
            for os in LightenUpGame.offset {
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
            self[p] = LightenUpObject(objType: move.objType, lightness: 0)
        case (.empty, .marker), (.marker, .empty):
            objChanged()
        case (.empty, .lightbulb), (.marker, .lightbulb):
            if normalLightbulbsOnly && self[p].lightness > 0 {break}
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
    
    func switchObject(move: inout LightenUpGameMove) -> Bool {
        let markerOption = LightenUpMarkerOptions(rawValue: self.markerOption)
        func f(o: LightenUpObjectType) -> LightenUpObjectType {
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
            move.objType = normalLightbulbsOnly && self[p].lightness > 0 ? f(o: o) : o
            return setObject(move: &move)
        case .wall:
            return false
        }
    }
    
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[r, c]
                switch o.objType {
                case .empty where o.lightness == 0, .marker where o.lightness == 0:
                    isSolved = false
                case .lightbulb:
                    let state: LightenUpLightbulbState = o.lightness == 1 ? .normal : .error
                    self[r, c].objType = .lightbulb(state: state)
                    if o.lightness > 1 {isSolved = false}
                case .wall:
                    let lightbulbs = game.wall2Lightbulbs[p]!
                    guard lightbulbs >= 0 else {break}
                    var n = 0
                    for os in LightenUpGame.offset {
                        let p2 = p + os
                        guard isValid(p: p2) else {continue}
                        if case .lightbulb = self[p2].objType {
                            n += 1
                        }
                    }
                    let state: HintState = n < lightbulbs ? .normal : n == lightbulbs ? .complete : .error
                    self[r, c].objType = .wall(state: state)
                    if n != lightbulbs {isSolved = false}
                default:
                    break
                }
            }
        }
    }
}
