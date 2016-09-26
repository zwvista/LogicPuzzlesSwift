//
//  GameState.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct GameState {
    let size: Position
    var objArray: [GameObject]
    var options: GameProgress { return GameDocument.sharedInstance.gameProgress }
    
    init(rows: Int, cols: Int) {
        self.size = Position(rows, cols)
        objArray = Array<GameObject>(repeating: GameObject(), count: rows * cols)
    }
    
    subscript(p: Position) -> GameObject {
        get {
            return objArray[p.row * size.col + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GameObject {
        get {
            return objArray[row * size.col + col]
        }
        set(newValue) {
            objArray[row * size.col + col] = newValue
        }
    }
    
    func isValid(p: Position) -> Bool {
        return isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return row >= 0 && col >= 0 && row < size.row && col < size.col
    }
    
    mutating func setObject(p: Position, objType: GameObjectType) -> (Bool, GameMove) {
        var changed = false
        var move = GameMove()
        
        func adjustLightness(tolighten: Bool) {
            let f = { lightness in
                tolighten ? lightness + 1 : lightness > 0 ? lightness - 1 : lightness;
            }
            
            self[p].lightness = f(self[p].lightness)
            for os in offset {
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
            move.p = p
            move.objType = objType
            self[p].objType = objType
        }
        
        switch (self[p].objType, objType) {
        case (_, .wall):
            self[p] = GameObject(objType: objType, lightness: 0)
        case (.empty, .marker), (.marker, .empty):
            objChanged()
        case (.empty, .lightbulb), (.marker, .lightbulb):
            objChanged()
            adjustLightness(tolighten: true)
        case (.lightbulb, .empty), (.lightbulb, .marker):
            objChanged()
            adjustLightness(tolighten: false)
        default:
            break
        }
        
        return (changed, move)
    }
    
    mutating func switchObject(p: Position) -> (Bool, GameMove) {
        switch self[p].objType {
        case .empty:
            return setObject(p: p, objType: options.useMarker ? .marker : .lightbulb(state: .normal))
        case .lightbulb:
            return setObject(p: p, objType: .empty)
        case .marker:
            return setObject(p: p, objType: .lightbulb(state: .normal))
        default:
            return (false, GameMove())
        }
    }
    
    private(set) var isSolved = false
    
    private mutating func updateIsSolved() {
        isSolved = true
        for r in 0 ..< size.row {
            for c in 0 ..< size.col {
                let p = Position(r, c)
                let o = self[r, c]
                switch o.objType {
                case .empty where o.lightness == 0, .marker where o.lightness == 0:
                    isSolved = false
                case .lightbulb:
                    let state: LightbulbState = o.lightness == 1 ? .normal : .error
                    self[r, c].objType = .lightbulb(state: state)
                    if o.lightness > 1 {isSolved = false}
                case let .wall(lightbulbs, _) where lightbulbs >= 0:
                    var n = 0
                    for os in offset {
                        let p2 = p + os
                        guard isValid(p: p2) else {continue}
                        if case .lightbulb = self[p2].objType {
                            n += 1
                        }
                    }
                    let state: WallState = n < lightbulbs ? .normal : n == lightbulbs ? .complete : .error
                    self[r, c].objType = .wall(lightbulbs: lightbulbs, state: state)
                    if n != lightbulbs {isSolved = false}
                default:
                    break
                }
            }
        }
    }
}
