//
//  SnakeIslandsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnakeIslandsGameState: GridGameState<SnakeIslandsGameMove> {
    var game: SnakeIslandsGame {
        get { getGame() as! SnakeIslandsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SnakeIslandsDocument.sharedInstance }
    var objArray = [SnakeIslandsObject]()
    var pos2state = [Position: HintState]()

    override func copy() -> SnakeIslandsGameState {
        let v = SnakeIslandsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SnakeIslandsGameState) -> SnakeIslandsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SnakeIslandsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<SnakeIslandsObject>(repeating: SnakeIslandsObject(), count: rows * cols)
        for (p, obj) in game.pos2obj {
            self[p] = obj
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> SnakeIslandsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> SnakeIslandsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout SnakeIslandsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), !self[p].isHint(), self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout SnakeIslandsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), !self[p].isHint() else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .wall
        case .wall: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .wall : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 4/Castle Patrol

        Summary
        Don't fall down the wall

        Description
        1. Divide the grid into walls and empty areas. Every area contains one number.
        2. The number indicates the size of the area. Numbers in wall tiles are part
           of wall areas; numbers in empty tiles are part of empty areas.
        3. Areas of the same type cannot share an edge.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngWalls = [Position]()
        var rngEmpty = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
                switch self[p] {
                case .wall, .wallHint:
                    rngWalls.append(p)
                case .empty, .emptyHint:
                    rngEmpty.append(p)
                default:
                    break
                }
            }
        }
        for p in rngWalls {
            for os in NurikabeGame.offset {
                let p2 = p + os
                if rngWalls.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        for p in rngEmpty {
            for os in NurikabeGame.offset {
                let p2 = p + os
                if rngEmpty.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        var areas = [[Position]]()
        var pos2area = [Position: Int]()
        func f(rngWE: inout [Position], hint: SnakeIslandsObject) {
            while !rngWE.isEmpty {
                let node = pos2node[rngWE.first!]!
                let nodesExplored = breadthFirstSearch(g, source: node)
                let area = rngWE.filter { nodesExplored.contains($0.description) }
                let rng = area.filter { self[$0].isHint() }
                rngWE = rngWE.filter { !nodesExplored.contains($0.description) }
                let n1 = nodesExplored.count
                if rng.count == 1 && self[rng[0]] == hint {
                    // 1. Divide the grid into walls and empty areas. Every area contains one number.
                    let p = rng[0]
                    let n2 = game.pos2hint[p]!
                    let s: HintState = hint == .wallHint && n1 < n2 ? .normal : n1 == n2 ? .complete : .error
                    pos2state[p] = s
                    if s != .complete { isSolved = false }
                    let n = areas.count
                    areas.append(area)
                    for p in area { pos2area[p] = n }
                } else {
                    isSolved = false
                    for p in rng { pos2state[p] = hint == .wallHint ? .error : .normal }
                }
            }
        }
        f(rngWE: &rngWalls, hint: .wallHint)
        f(rngWE: &rngEmpty, hint: .emptyHint)
        guard isSolved else {return}
        // 3. Areas of the same type cannot share an edge.
        if !areas.allSatisfy({ area in
            let p0 = area[0]
            let n = pos2area[p0]!
            let obj = self[p0]
            return area.allSatisfy({ p in
                return SnakeIslandsGame.offset.allSatisfy({
                    guard let n2 = pos2area[p + $0], n2 != n else { return true }
                    return self[areas[n2][0]] != obj
                })
            })
        }) { isSolved = false }
    }
}
