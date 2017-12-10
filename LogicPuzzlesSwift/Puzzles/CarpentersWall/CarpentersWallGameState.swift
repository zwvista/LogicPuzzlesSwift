//
//  CarpentersWallGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CarpentersWallGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: CarpentersWallGame {
        get {return getGame() as! CarpentersWallGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: CarpentersWallDocument { return CarpentersWallDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return CarpentersWallDocument.sharedInstance }
    var objArray = [CarpentersWallObject]()
    
    override func copy() -> CarpentersWallGameState {
        let v = CarpentersWallGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CarpentersWallGameState) -> CarpentersWallGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CarpentersWallGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> CarpentersWallObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> CarpentersWallObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout CarpentersWallGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        guard !o1.isHint() && String(describing: o1) != String(describing: o2) else {return false}
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout CarpentersWallGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: CarpentersWallObject) -> CarpentersWallObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .wall
            case .wall:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .wall : .empty
            default:
                return o
            }
        }
        let o = self[move.p]
        guard !o.isHint() else {return false}
        move.obj = f(o: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 12/Carpenter's Wall

        Summary
        Angled Walls

        Description
        1. In this game you have to create a valid Nurikabe following a different
           type of hints.
        2. In the end, the empty spaces left by the Nurikabe will form many Carpenter's
           Squares (L shaped tools) of different size.
        3. The circled numbers on the board indicate the corner of the L.
        4. When a number is inside the circle, that indicates the total number of
           squares occupied by the L.
        5. The arrow always sits at the end of an arm and points to the corner of
           an L.
        6. Not all the Carpenter's Squares might be indicated: some could be hidden
           and no hint given.
    */
    private func updateIsSolved() {
        isSolved = true
        // 7. The wall can't form 2*2 squares.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if CarpentersWallGame.offset2.testAll({os in
                    let o = self[p + os]
                    if case .wall = o {return true} else {return false}
                }) {isSolved = false}
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
                if case .wall = self[p] {
                    rngWalls.append(p)
                } else {
                    rngEmpty.append(p)
                }
                switch self[p] {
                case let .corner(n, _):
                    self[p] = .corner(tiles: n, state: .normal)
                case .left:
                    self[p] = .left(state: .normal)
                case .up:
                    self[p] = .up(state: .normal)
                case .right:
                    self[p] = .right(state: .normal)
                case .down:
                    self[p] = .down(state: .normal)
                default:
                    break
                }
            }
        }
        for p in rngWalls {
            for os in CarpentersWallGame.offset {
                let p2 = p + os
                if rngWalls.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        for p in rngEmpty {
            for os in CarpentersWallGame.offset {
                let p2 = p + os
                if rngEmpty.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        if rngWalls.isEmpty {
            isSolved = false
        } else {
            // 3. The garden is separated by a single continuous wall. This means all
            // wall tiles on the board must be connected horizontally or vertically.
            // There can't be isolated walls.
            let nodesExplored = breadthFirstSearch(g, source: pos2node[rngWalls.first!]!)
            if rngWalls.count != nodesExplored.count {isSolved = false}
        }
        while !rngEmpty.isEmpty {
            let node = pos2node[rngEmpty.first!]!
            let nodesExplored = breadthFirstSearch(g, source: node)
            let area = rngEmpty.filter{nodesExplored.contains($0.description)}
            let rngHint = area.filter{self[$0].isHint()}
            rngEmpty = rngEmpty.filter{!nodesExplored.contains($0.description)}
            let n1 = nodesExplored.count
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in area {
                if r2 < p.row {r2 = p.row}
                if r1 > p.row {r1 = p.row}
                if c2 < p.col {c2 = p.col}
                if c1 > p.col {c1 = p.col}
            }
            if r1 == r2 || c1 == c2 {isSolved = false; continue}
            let cntR1 = area.filter{$0.row == r1}.count
            let cntR2 = area.filter{$0.row == r2}.count
            let cntC1 = area.filter{$0.col == c1}.count
            let cntC2 = area.filter{$0.col == c2}.count
            func f(_ a: Int, _ b: Int) -> Bool {return a > 1 && b > 1 && a + b - 1 == n1}
            let squareType =
                f(cntR1, cntC1) ? 0 : // ┌
                f(cntR1, cntC2) ? 1 : // ┐
                f(cntR2, cntC1) ? 2 : // └
                f(cntR2, cntC2) ? 3 : -1 // ┘
            for p in rngHint {
                switch self[p] {
                case let .corner(n2, _):
                    let s: HintState = squareType == -1 ? .normal : !(n1 == n2 || n2 == 0) ? .error : squareType == 0 && p == Position(r1, c1) || squareType == 1 && p == Position(r1, c2) || squareType == 2 && p == Position(r2, c1) || squareType == 3 && p == Position(r2, c2) ? .complete : .error
                    self[p] = .corner(tiles: n2, state: s)
                    if s != .complete {isSolved = false}
                case .left:
                    let s: HintState = squareType == -1 ? .normal : squareType == 0 && p == Position(r1, c2) || squareType == 2 && p == Position(r2, c2) ? .complete : .error
                    self[p] = .left(state: s)
                    if s != .complete {isSolved = false}
                case .up:
                    let s: HintState = squareType == -1 ? .normal : squareType == 0 && p == Position(r2, c1) || squareType == 1 && p == Position(r2, c2) ? .complete : .error
                    self[p] = .up(state: s)
                    if s != .complete {isSolved = false}
                case .right:
                    let s: HintState = squareType == -1 ? .normal : squareType == 1 && p == Position(r1, c1) || squareType == 3 && p == Position(r2, c1) ? .complete : .error
                    self[p] = .right(state: s)
                    if s != .complete {isSolved = false}
                case .down:
                    let s: HintState = squareType == -1 ? .normal : squareType == 2 && p == Position(r1, c1) || squareType == 3 && p == Position(r1, c2) ? .complete : .error
                    self[p] = .down(state: s)
                    if s != .complete {isSolved = false}
                default:
                    break
                }
            }
        }
    }
}
