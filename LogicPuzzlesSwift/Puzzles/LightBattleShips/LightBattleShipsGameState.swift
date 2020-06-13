//
//  LightBattleShipsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightBattleShipsGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: LightBattleShipsGame {
        get { getGame() as! LightBattleShipsGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: LightBattleShipsDocument { LightBattleShipsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { LightBattleShipsDocument.sharedInstance }
    var objArray = [LightBattleShipsObject]()
    
    override func copy() -> LightBattleShipsGameState {
        let v = LightBattleShipsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LightBattleShipsGameState) -> LightBattleShipsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LightBattleShipsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LightBattleShipsObject>(repeating: LightBattleShipsObject(), count: rows * cols)
        for (p, obj) in game.pos2obj {
            self[p] = obj
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> LightBattleShipsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LightBattleShipsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func setObject(move: inout LightBattleShipsGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return false }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout LightBattleShipsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: LightBattleShipsObject) -> LightBattleShipsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .battleShipUnit
            case .battleShipUnit:
                return .battleShipMiddle
            case .battleShipMiddle:
                return .battleShipLeft
            case .battleShipLeft:
                return .battleShipTop
            case .battleShipTop:
                return .battleShipRight
            case .battleShipRight:
                return .battleShipBottom
            case .battleShipBottom:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .battleShipUnit : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else { return false }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 13/Light Battle Ships

        Summary
        Please divert your course 15 degrees to avoid collision

        Description
        1. A mix of Battle Ships and Lighthouses, you have to guess the usual
           piece of ships with the help of Lighthouses.
        2. Each number is a Lighthouse, telling you how many pieces of ship
           there are in that row and column, summed together.
        3. Ships cannot touch each other OR touch Lighthouses. Not even diagonally.
        4. In each puzzle there are
           1 Aircraft Carrier (4 squares)
           2 Destroyers (3 squares)
           3 Submarines (2 squares)
           4 Patrol boats (1 square)

        Variant
        5. Some puzzle can also have a:
           1 Supertanker (5 squares)
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] { self[r, c] = .empty }
            }
        }
        // 3. Ships cannot touch Lighthouses. Not even diagonally.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor(isHint: Bool) -> Bool {
                    for os in LightBattleShipsGame.offset {
                        let p2 = p + os
                        guard isValid(p: p2) else {continue}
                        switch self[p2] {
                        case .hint:
                            if !isHint { return true }
                        case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                            if isHint { return true }
                        default:
                            break
                        }
                    }
                    return false
                }
                switch self[p] {
                case .hint:
                    let s: HintState = !hasNeighbor(isHint: true) ? .normal : .error
                    self[p] = .hint(state: s)
                    if s == .error { isSolved = false }
                case .empty, .marker:
                    guard allowedObjectsOnly && hasNeighbor(isHint: false) else {continue}
                    self[p] = .forbidden
                default:
                    break
                }
            }
        }
        // 2. Each number is a Lighthouse, telling you how many pieces of ship
        // there are in that row and column, summed together.
        for (p, n2) in game.pos2hint {
            var nums = [0, 0, 0, 0]
            var rng = [Position]()
            for i in 0..<4 {
                let os = LightBattleShipsGame.offset[i * 2]
                var p2 = p + os
                while game.isValid(p: p2) {
                    switch self[p2] {
                    case .empty:
                        rng.append(p2)
                    case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                        nums[i] += 1
                    default:
                        break
                    }
                    p2 += os
                }
            }
            let n1 = nums.reduce(0, +)
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if case let .hint(state) = self[p], state != .error { self[p] = .hint(state: s) }
            if s != .complete {
                isSolved = false
            } else if allowedObjectsOnly {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[r, c] {
                case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                    let node = g.addNode(p.description)
                    pos2node[p] = node
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            for i in 0..<4 {
                let p2 = p + LightBattleShipsGame.offset[i * 2]
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        var shipNumbers = Array<Int>(repeating: 0, count: 5)
        while pos2node.count > 0 {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter{ nodesExplored.contains($0.0.description) }.map{ $0.0 }.sorted()
            pos2node = pos2node.filter{ !nodesExplored.contains($0.0.description) }
            guard area.count == 1 && String(describing: self[area.first!]) == String(describing: LightBattleShipsObject.battleShipUnit) || area.count > 1 && area.count < 5 && (
                area.testAll({ $0.row == area.first!.row }) && String(describing: self[area.first!]) == String(describing: LightBattleShipsObject.battleShipLeft) && String(describing: self[area.last!]) == String(describing: LightBattleShipsObject.battleShipRight) ||
                area.testAll({ $0.col == area.first!.col }) && String(describing: self[area.first!]) == String(describing: LightBattleShipsObject.battleShipTop) && String(describing: self[area.last!]) == String(describing: LightBattleShipsObject.battleShipBottom)) &&
                [Int](1..<area.count - 1).testAll({ String(describing: self[area[$0]]) == String(describing: LightBattleShipsObject.battleShipMiddle) }) else { isSolved = false; continue }
            for p in area {
                for os in LightBattleShipsGame.offset {
                    // 3. Ships cannot touch each other. Not even diagonally.
                    let p2 = p + os
                    if !self.isValid(p: p2) || area.contains(p2) {continue}
                    switch self[p2] {
                    case .empty, .marker, .forbidden:
                        if allowedObjectsOnly { self[p2] = .forbidden }
                    default:
                        isSolved = false
                    }
                }
            }
            shipNumbers[area.count] += 1
        }
        // 4. In each puzzle there are
        //    1 Aircraft Carrier (4 squares)
        //    2 Destroyers (3 squares)
        //    3 Submarines (2 squares)
        //    4 Patrol boats (1 square)
        if shipNumbers != [0, 4, 3, 2, 1] { isSolved = false }
    }
}
