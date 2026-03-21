//
//  LightenUpGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightenUpGameState: GridGameState<LightenUpGameMove> {
    var game: LightenUpGame {
        get { getGame() as! LightenUpGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LightenUpDocument.sharedInstance }
    var objArray = [LightenUpObject]()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    
    override func copy() -> LightenUpGameState {
        let v = LightenUpGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LightenUpGameState) -> LightenUpGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LightenUpGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LightenUpObject>(repeating: LightenUpObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p].objType = .wall
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> LightenUpObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LightenUpObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout LightenUpGameMove) -> GameOperationType {
        var changed = false
        let p = move.p
        
        func adjustLightness(tolighten: Bool) {
            func f(lightness: inout Int) {
                lightness = tolighten ? lightness + 1 : max(0, lightness - 1)
            }
            f(lightness: &self[p].lightness)
            // 3. Lightbulbs light all free, unblocked squares horizontally and vertically.
            for os in LightenUpGame.offset {
                var p2 = p + os
                // 5. Walls block light.
                while isValid(p: p2) && self[p2].objType != .wall {
                    f(lightness: &self[p2].lightness)
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
            if allowedObjectsOnly && self[p].lightness > 0 {break}
            objChanged()
            adjustLightness(tolighten: true)
        case (.lightbulb, .empty), (.lightbulb, .marker):
            objChanged()
            adjustLightness(tolighten: false)
        default:
            break
        }
        
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout LightenUpGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let allowedObjectsOnly = self.allowedObjectsOnly
        let markerOption = MarkerOptions(rawValue: markerOption)
        func f(o: LightenUpObjectType) -> LightenUpObjectType {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .lightbulb
            case .lightbulb:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .lightbulb : .empty
            case .wall:
                return o
            }
        }
        let o = f(o: self[p].objType)
        switch o {
        case .empty, .marker:
            move.objType = o
            return setObject(move: &move)
        case .lightbulb:
            move.objType = allowedObjectsOnly && self[p].lightness > 0 ? f(o: o) : o
            return setObject(move: &move)
        case .wall:
            return .invalid
        }
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 2/Lighten Up

        Summary
        Place lightbulbs to light up all the room squares

        Description
        1. What you see from above is a room and the marked squares are walls.
        2. The goal is to put lightbulbs in the room so that all the blank(non-wall)
           squares are lit, following these rules.
        3. Lightbulbs light all free, unblocked squares horizontally and vertically.
        4. A lightbulb can't light another lightbulb.
        5. Walls block light. Also walls with a number tell you how many lightbulbs
           are adjacent to it, horizontally and vertically.
        6. Walls without a number can have any number of lightbulbs. However,
           lightbulbs don't need to be adjacent to a wall.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                switch o.objType {
                case .lightbulb:
                    // 4. A lightbulb can't light another lightbulb.
                    let s: AllowedObjectState = o.lightness == 1 ? .normal : .error
                    pos2stateAllowed[p] = s
                    if s == .error { isSolved = false }
                case .wall:
                    let n2 = game.pos2hint[p]!
                    // 6. Walls without a number can have any number of lightbulbs.
                    guard n2 >= 0 else { pos2stateHint[p] = .normal; break }
                    var n1 = 0
                    for os in LightenUpGame.offset {
                        let p2 = p + os
                        if isValid(p: p2) && self[p2].objType == .lightbulb { n1 += 1 }
                    }
                    // 5. Walls with a number tell you how many lightbulbs
                    // are adjacent to it, horizontally and vertically.
                    let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
                    pos2stateHint[p] = s
                    if s != .complete { isSolved = false }
                default:
                    // 2. The goal is to put lightbulbs in the room so that all the blank(non-wall)
                    // squares are lit.
                    if o.lightness == 0 { isSolved = false }
                }
            }
        }
    }
}
