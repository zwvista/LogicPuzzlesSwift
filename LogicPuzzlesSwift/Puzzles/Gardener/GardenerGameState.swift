//
//  GardenerGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GardenerGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: GardenerGame {
        get {return getGame() as! GardenerGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: GardenerDocument { return GardenerDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return GardenerDocument.sharedInstance }
    var objArray = [GardenerObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> GardenerGameState {
        let v = GardenerGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: GardenerGameState) -> GardenerGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: GardenerGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<GardenerObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> GardenerObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GardenerObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout GardenerGameMove) -> Bool {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout GardenerGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GardenerObject) -> GardenerObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tree(state: .normal)
            case .tree:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tree(state: .normal) : .empty
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
        iOS Game: Logic Games/Puzzle Set 7/Gardener

        Summary
        Hitori Flower Planting

        Description
        1. The Board represents a Garden, divided in many rectangular Flowerbeds.
        2. The owner of the Garden wants you to plant Flowers according to these
           rules.
        3. A number tells you how many Flowers you must plant in that Flowerbed.
           A Flowerbed without number can have any quantity of Flowers.
        4. Flowers can't be horizontally or vertically touching.
        5. All the remaining Garden space where there are no Flowers must be
           interconnected (horizontally or vertically), as he wants to be able
           to reach every part of the Garden without treading over Flowers.
        6. Lastly, there must be enough balance in the Garden, so a straight
           line (horizontally or vertically) of non-planted tiles can't span
           for more than two Flowerbeds.
        7. In other words, a straight path of empty space can't pass through
           three or more Flowerbeds.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] {self[r, c] = .empty}
            }
        }
        for (p, (n2, i)) in game.pos2hint {
            let area = game.areas[i]
            var n1 = 0
            for p in area {
                if case .tree = self[p] {n1 += 1}
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            pos2state[p] = s
            if s != .complete {isSolved = false}
            if s != .normal && allowedObjectsOnly {
                for p in area {
                    switch self[p] {
                    case .empty, .marker:
                        self[p] = .forbidden
                    default:
                        break
                    }
                }
            }
        }
        var trees = [Position]()
        func areTreesInvalid() -> Bool {
            return Set<Int>(trees.map{game.pos2area[$0]!}).count > 2
        }
        func checkTrees() {
            if areTreesInvalid() {
                isSolved = false
                for p in trees {
                    self[p] = .tree(state: .error)
                }
            }
            trees.removeAll()
        }
        func checkForbidden(p: Position, indexes: [Int]) {
            guard allowedObjectsOnly else {return}
            for i in indexes {
                let os = GardenerGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) {
                    guard case .tree = self[p2] else {break}
                    trees.append(p2)
                    p2 += os
                }
            }
            if areTreesInvalid() {self[p] = .forbidden}
            trees.removeAll()
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .tree:
                    trees.append(p)
                case .empty, .marker:
                    checkTrees()
                    checkForbidden(p: p, indexes: [1,3])
                default:
                    checkTrees()
                }
            }
            checkTrees()
        }
        for c in 0..<cols {
            for r in 0..<rows {
                let p = Position(r, c)
                switch self[p] {
                case .tree:
                    trees.append(p)
                case .empty, .marker:
                    checkTrees()
                    checkForbidden(p: p, indexes: [0,2])
                default:
                    checkTrees()
                }
            }
            checkTrees()
        }
    }
}
