//
//  PaintTheNurikabeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PaintTheNurikabeGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: PaintTheNurikabeGame {
        get {return getGame() as! PaintTheNurikabeGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: PaintTheNurikabeDocument { return PaintTheNurikabeDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return PaintTheNurikabeDocument.sharedInstance }
    var objArray = [PaintTheNurikabeObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> PaintTheNurikabeGameState {
        let v = PaintTheNurikabeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PaintTheNurikabeGameState) -> PaintTheNurikabeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: PaintTheNurikabeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<PaintTheNurikabeObject>(repeating: PaintTheNurikabeObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> PaintTheNurikabeObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> PaintTheNurikabeObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout PaintTheNurikabeGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        guard String(describing: o1) != String(describing: o2) else {return false}
        for p2 in game.areas[game.pos2area[p]!] {
            self[p2] = move.obj
        }
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout PaintTheNurikabeGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: PaintTheNurikabeObject) -> PaintTheNurikabeObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .painting
            case .painting:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .painting : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 6/Paint The Nurikabe

        Summary
        Paint areas, find Nurikabes

        Description
        1. By painting (filling) the areas you have to complete a Nurikabe.
           Specifically:
        2. A number indicates how many painted tiles are adjacent to it.
        3. The painted tiles form an orthogonally continuous area, like a
           Nurikabe.
        4. There can't be any 2*2 area of the same color(painted or empty).
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if case .forbidden = self[p] {self[p] = .empty}
            }
        }
        for (p, n2) in game.pos2hint {
            var rng = [Position]()
            var n1 = 0
            for os in PaintTheNurikabeGame.offset {
                let p2 = p + os
                guard game.isValid(p: p2) else {continue}
                switch self[p2] {
                case .painting:
                    n1 += 1
                case .empty:
                    rng.append(p2)
                default:
                    break
                }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {
                isSolved = false
            } else if allowedObjectsOnly {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
    }
}
