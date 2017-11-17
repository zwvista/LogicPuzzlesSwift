//
//  HolidayIslandGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HolidayIslandGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: HolidayIslandGame {
        get {return getGame() as! HolidayIslandGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: HolidayIslandDocument { return HolidayIslandDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return HolidayIslandDocument.sharedInstance }
    var objArray = [HolidayIslandObject]()
    
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
        for (p, n) in game.pos2hint {
            self[p] = .hint(tiles: n, state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> HolidayIslandObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> HolidayIslandObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout HolidayIslandGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) else {return false}
        if case .hint = self[p] {return false}
        guard String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout HolidayIslandGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: HolidayIslandObject) -> HolidayIslandObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tree
            case .tree:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tree : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        if case .hint = self[p] {return false}
        move.obj = f(o: self[p])
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
        var rngHints = [Position]()
        var g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case let .hint(tiles, _):
                    self[p] = .hint(tiles: tiles, state: .normal)
                    rngHints.append(p)
                default:
                    break
                }
            }
        }
        func addNodes() {
            for r in 0..<rows {
                for c in 0..<cols {
                    let p = Position(r, c)
                    if case .tree = self[p] {continue}
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        addNodes()
        for (p, node) in pos2node {
            for os in HolidayIslandGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        do {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            if nodesExplored.count != pos2node.count {isSolved = false}
        }
        for pHint in rngHints {
            g = Graph()
            pos2node.removeAll()
            addNodes()
            for (p, node) in pos2node {
                for os in HolidayIslandGame.offset {
                    let p2 = p + os
                    guard let node2 = pos2node[p2] else {continue}
                    if case .hint = self[p2] {continue}
                    g.addEdge(node, neighbor: node2)
                }
            }
            guard case let .hint(n2, _) = self[pHint] else {continue}
            let nodesExplored = breadthFirstSearch(g, source: pos2node[pHint]!)
            let n1 = nodesExplored.count - 1
            let s: HintState = n1 > n2 ? .normal : n1 == n2 ? .complete : .error
            self[pHint] = .hint(tiles: n2, state: s)
            if s != .complete {isSolved = false}
            if allowedObjectsOnly && n1 <= n2 {
                for node in nodesExplored {
                    let p2 = pos2node.filter{$0.0.description == node}.first!.key
                    guard p2 != pHint else {continue}
                    self[p2] = .forbidden
                }
            }
        }
    }
}
