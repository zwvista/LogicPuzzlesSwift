//
//  PairakabeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PairakabeGameState: GridGameState, PairakabeMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: PairakabeGame {
        get {return getGame() as! PairakabeGame}
        set {setGame(game: newValue)}
    }
    var objArray = [PairakabeObject]()
    
    override func copy() -> PairakabeGameState {
        let v = PairakabeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PairakabeGameState) -> PairakabeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PairakabeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<PairakabeObject>(repeating: PairakabeObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> PairakabeObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> PairakabeObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout PairakabeGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 {return false}
        guard String(describing: o1) != String(describing: o2) else {return false}
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout PairakabeGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: PairakabeObject) -> PairakabeObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .wall
            case .wall:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .wall : .empty
            case .hint:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 12/Pairakabe

        Summary
        Just to confuse things a bit more

        Description
        1. Plays like Nurikabe, with an interesting twist.
        2. Instead of just one number, each 'garden' contains two numbers and
           the area of the garden is given by the sum of both.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows - 1 {
            rule2x2:
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for os in PairakabeGame.offset2 {
                    guard case .wall = self[p + os] else {continue rule2x2}
                }
                isSolved = false
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngWalls = [Position]()
        var rngEmpty = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
                switch self[p] {
                case .wall:
                    rngWalls.append(p)
                default:
                    rngEmpty.append(p)
                }
            }
        }
        for p in rngWalls {
            for os in PairakabeGame.offset {
                let p2 = p + os
                if rngWalls.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        for p in rngEmpty {
            for os in PairakabeGame.offset {
                let p2 = p + os
                if rngEmpty.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        if rngWalls.isEmpty {
            isSolved = false
        } else {
            let nodesExplored = breadthFirstSearch(g, source: pos2node[rngWalls.first!]!)
            if rngWalls.count != nodesExplored.count {isSolved = false}
        }
        while !rngEmpty.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node[rngEmpty.first!]!)
            rngEmpty = rngEmpty.filter({p in !nodesExplored.contains(p.description)})
            let n2 = nodesExplored.count
            var rng = [Position]()
            for p in game.pos2hint.keys {
                if nodesExplored.contains(p.description) {
                    rng.append(p)
                }
            }
            switch rng.count {
            case 0:
                isSolved = false
            case 1:
                self[rng[0]] = .hint(state: .error)
            case 2:
                let p1 = rng[0], p2 = rng[1]
                let n1 = game.pos2hint[p1]! + game.pos2hint[p2]!
                let s: HintState = n1 == n2 ? .complete : .error
                self[p1] = .hint(state: s)
                self[p2] = .hint(state: s)
                if s != .complete {isSolved = false}
            default:
                for p in rng {
                    self[p] = .hint(state: .normal)
                }
                isSolved = false
            }
        }
    }
}
