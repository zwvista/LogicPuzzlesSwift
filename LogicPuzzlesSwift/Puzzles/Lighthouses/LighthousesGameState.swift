//
//  LighthousesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LighthousesGameState: GridGameState, LighthousesMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: LighthousesGame {
        get {return getGame() as! LighthousesGame}
        set {setGame(game: newValue)}
    }
    var objArray = [LighthousesObject]()
    
    override func copy() -> LighthousesGameState {
        let v = LighthousesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LighthousesGameState) -> LighthousesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LighthousesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LighthousesObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> LighthousesObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> LighthousesObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout LighthousesGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 {return false}
        guard String(describing: o1) != String(describing: o2) else {return false}
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout LighthousesGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: LighthousesObject) -> LighthousesObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .lighthouse(state: .normal)
            case .lighthouse:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .lighthouse(state: .normal) : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .lighthouse:
                    self[p] = .lighthouse(state: .normal)
                case .forbidden:
                    self[p] = .empty
                default:
                    break
                }
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor() -> Bool {
                    for os in LighthousesGame.offset {
                        let p2 = p + os
                        guard isValid(p: p2) else {continue}
                        switch self[p2] {
                        case .hint, .lighthouse:
                            return true
                        default:
                            break
                        }
                    }
                    return false
                }
                func hasLightedBoat() -> Bool {
                    for i in 0..<4 {
                        let os = LighthousesGame.offset[i * 2]
                        var p2 = p + os
                        while game.isValid(p: p2) {
                            if case .hint = self[p2] {return true}
                            p2 += os
                        }
                    }
                    return false
                }
                switch self[p] {
                case let .lighthouse(state):
                    self[p] = .lighthouse(state: state == .normal && !hasNeighbor() && hasLightedBoat() ? .normal : .error)
                case .empty, .marker:
                    guard allowedObjectsOnly && hasNeighbor() else {continue}
                    self[p] = .forbidden
                default:
                    break
                }
            }
        }
        for (p, n2) in game.pos2hint {
            var nums = [0, 0, 0, 0]
            var rng = [Position]()
            for i in 0..<4 {
                let os = LighthousesGame.offset[i * 2]
                var p2 = p + os
                while game.isValid(p: p2) {
                    switch self[p2] {
                    case .empty:
                        rng.append(p2)
                    case .lighthouse:
                        nums[i] += 1
                    default:
                        break
                    }
                    p2 += os
                }
            }
            let n1 = nums.reduce(0, +)
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {
                isSolved = false
            } else {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
    }
}
