//
//  CarpentersSquareGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CarpentersSquareGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: CarpentersSquareGame {
        get {getGame() as! CarpentersSquareGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: CarpentersSquareDocument { return CarpentersSquareDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return CarpentersSquareDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> CarpentersSquareGameState {
        let v = CarpentersSquareGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CarpentersSquareGameState) -> CarpentersSquareGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: CarpentersSquareGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> GridDotObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout CarpentersSquareGameMove) -> Bool {
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let dir = move.dir, dir2 = (dir + 2) % 4
        let p = move.p, p2 = p + CarpentersSquareGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else {return false}
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed {updateIsSolved()}
        return changed
    }
    
    func switchObject(move: inout CarpentersSquareGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            default:
                return o
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 16/Carpenter's Square

        Summary
        Angled Borders

        Description
        1. Similar to Carpenter's Wall, this time you have to respect the same
           rules, but instead of forming a Nurikabe, you just have to divide the
           board into many.Capenter's Squares (L shaped tools) of different size.
        2. The circled numbers on the board indicate the corner of the L.
        3. When a number is inside the circle, that indicates the total number of
           squares occupied by the L.
        4. The arrow always sits at the end of an arm and points to the corner of
           an L.
        5. All the tiles in the board have to be part of a Carpenter's Square.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
            }
        }
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for i in 0..<4 {
                    guard self[p + CarpentersSquareGame.offset2[i]][CarpentersSquareGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + CarpentersSquareGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter{nodesExplored.contains($0.0.description)}.map{$0.0}
            pos2node = pos2node.filter{!nodesExplored.contains($0.0.description)}
            let rngHint = area.filter{game.pos2hint[$0] != nil}
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
            // 1. You just have to divide the board into many.Capenter's Squares (L shaped tools) of different size.
            let squareType =
                f(cntR1, cntC1) ? 0 : // ┌
                f(cntR1, cntC2) ? 1 : // ┐
                f(cntR2, cntC1) ? 2 : // └
                f(cntR2, cntC2) ? 3 : -1 // ┘
            // 5. All the tiles in the board have to be part of a Carpenter's Square.
            if squareType == -1 {isSolved = false}
            for p in rngHint {
                switch game.pos2hint[p]! {
                case let .corner(n2):
                    // 2. The circled numbers on the board indicate the corner of the L.
                    // 3. When a number is inside the circle, that indicates the total number of
                    // squares occupied by the L.
                    let s: HintState = squareType == -1 ? .normal : !(n1 == n2 || n2 == 0) ? .error : squareType == 0 && p == Position(r1, c1) || squareType == 1 && p == Position(r1, c2) || squareType == 2 && p == Position(r2, c1) || squareType == 3 && p == Position(r2, c2) ? .complete : .error
                    pos2state[p] = s
                    if s != .complete {isSolved = false}
                case .left:
                    // 4. The arrow always sits at the end of an arm and points to the corner of
                    // an L.
                    let s: HintState = squareType == -1 ? .normal : squareType == 0 && p == Position(r1, c2) || squareType == 2 && p == Position(r2, c2) ? .complete : .error
                    pos2state[p] = s
                    if s != .complete {isSolved = false}
                case .up:
                    // 4. The arrow always sits at the end of an arm and points to the corner of
                    // an L.
                    let s: HintState = squareType == -1 ? .normal : squareType == 0 && p == Position(r2, c1) || squareType == 1 && p == Position(r2, c2) ? .complete : .error
                    pos2state[p] = s
                    if s != .complete {isSolved = false}
                case .right:
                    // 4. The arrow always sits at the end of an arm and points to the corner of
                    // an L.
                    let s: HintState = squareType == -1 ? .normal : squareType == 1 && p == Position(r1, c1) || squareType == 3 && p == Position(r2, c1) ? .complete : .error
                    pos2state[p] = s
                    if s != .complete {isSolved = false}
                case .down:
                    // 4. The arrow always sits at the end of an arm and points to the corner of
                    // an L.
                    let s: HintState = squareType == -1 ? .normal : squareType == 2 && p == Position(r1, c1) || squareType == 3 && p == Position(r1, c2) ? .complete : .error
                    pos2state[p] = s
                    if s != .complete {isSolved = false}
                default:
                    break
                }
            }
        }
    }
}
