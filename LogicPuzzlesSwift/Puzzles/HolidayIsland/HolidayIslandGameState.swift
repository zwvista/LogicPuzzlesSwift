//
//  HolidayIslandGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HolidayIslandGameState: GridGameState<HolidayIslandGameMove> {
    var game: HolidayIslandGame {
        get { getGame() as! HolidayIslandGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { HolidayIslandDocument.sharedInstance }
    var objArray = [HolidayIslandObject]()
    var pos2state = [Position: HintState]()

    override func copy() -> HolidayIslandGameState {
        let v = HolidayIslandGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: HolidayIslandGameState) -> HolidayIslandGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: HolidayIslandGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<HolidayIslandObject>(repeating: .empty, count: rows * cols)
        for (p, _) in game.pos2hint {
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> HolidayIslandObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> HolidayIslandObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout HolidayIslandGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil, String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout HolidayIslandGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil else { return .invalid }
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .water
        case .water: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .water : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 11/Holiday Island

        Summary
        This time the campers won't have their way!

        Description
        1. This time the resort is an island, the place is packed and the campers
           (Tents) must compromise!
        2. The board represents an Island, where there are a few Tents, identified
           by the numbers.
        3. Your job is to find the water surrounding the island, with these rules:
        4. There is only one, continuous island.
        5. The numbers tell you how many tiles that camper can walk from his Tent,
           by moving horizontally or vertically. A camper can't cross water or
           other Tents.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        var g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .forbidden {
                    self[p] = .empty
                }
                if self[p] != .water {
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        for (p, node) in pos2node {
            for os in HolidayIslandGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        do {
            // 4. There is only one, continuous island.
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            if nodesExplored.count != pos2node.count { isSolved = false }
        }
        g = Graph()
        pos2node.removeAll()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .water, .hint:
                    // 5. A camper can't cross water or other Tents.
                    break
                default:
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        for (p, node) in pos2node {
            for os in HolidayIslandGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        var areas = [[Position]]()
        var pos2area = [Position: Int]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let n = areas.count
            for p in area {
                pos2area[p] = n
            }
            areas.append(area)
        }
        for (p, n2) in game.pos2hint {
            var rng = Set<Position>()
            for os in HolidayIslandGame.offset {
                let p2 = p + os
                guard let i = pos2area[p2] else {continue}
                rng = rng.union(areas[i])
            }
            let n1 = rng.count
            // 5. The numbers tell you how many tiles that camper can walk from his Tent,
            // by moving horizontally or vertically.
            let s: HintState = n1 > n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
            if allowedObjectsOnly && n1 <= n2 {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
    }
}
