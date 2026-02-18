//
//  LightBattleShipsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightBattleShipsGameState: GridGameState<LightBattleShipsGameMove> {
    var game: LightBattleShipsGame {
        get { getGame() as! LightBattleShipsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LightBattleShipsDocument.sharedInstance }
    var objArray = [LightBattleShipsObject]()
    var pos2state = [Position: HintState]()

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
    
    override func setObject(move: inout LightBattleShipsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game.pos2obj[p] == nil && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout LightBattleShipsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game.pos2obj[p] == nil else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .battleShipUnit
        case .battleShipUnit: .battleShipMiddle
        case .battleShipMiddle: .battleShipLeft
        case .battleShipLeft: .battleShipTop
        case .battleShipTop: .battleShipRight
        case .battleShipRight: .battleShipBottom
        case .battleShipBottom: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .battleShipUnit : .empty
        default: o
        }
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
                if self[r, c] == .forbidden { self[r, c] = .empty }
            }
        }
        // 3. Ships cannot touch Lighthouses. Not even diagonally.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func touchHint(isHint: Bool) -> Bool {
                    LightBattleShipsGame.offset2.contains {
                        let p2 = p + $0
                        guard isValid(p: p2) else {return false}
                        let o = self[p2]
                        return !isHint && o == .hint || isHint && o.isShipPiece
                    }
                }
                switch self[p] {
                case .hint:
                    let s: HintState = !touchHint(isHint: true) ? .normal : .error
                    pos2state[p] = s
                    if s == .error { isSolved = false }
                case .empty, .marker:
                    guard allowedObjectsOnly && touchHint(isHint: false) else {continue}
                    self[p] = .forbidden
                default:
                    break
                }
            }
        }
        // 2. Each number is a Lighthouse, telling you how many pieces of ship
        // there are in that row and column, summed together.
        for (p, n2) in game.pos2hint {
            var n1 = 0
            var rng = [Position]()
            for os in LightBattleShipsGame.offset {
                var p2 = p + os
                while game.isValid(p: p2) {
                    let o = self[p2]
                    if o == .empty {
                        rng.append(p2)
                    } else if o.isShipPiece {
                        n1 += 1
                    }
                    p2 += os
                }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if pos2state[p] != .error { pos2state[p] = s }
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
                let o = self[p]
                if o.isShipPiece {
                    let node = g.addNode(p.description)
                    pos2node[p] = node
                }
            }
        }
        for (p, node) in pos2node {
            for os in LightBattleShipsGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        var shipNumbers = Array<Int>(repeating: 0, count: 5)
        while pos2node.count > 0 {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }.sorted()
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            guard area.count == 1 && String(describing: self[area.first!]) == String(describing: LightBattleShipsObject.battleShipUnit) || 2...4 ~= area.count && (
                area.testAll({ $0.row == area.first!.row }) && String(describing: self[area.first!]) == String(describing: LightBattleShipsObject.battleShipLeft) && String(describing: self[area.last!]) == String(describing: LightBattleShipsObject.battleShipRight) ||
                area.testAll({ $0.col == area.first!.col }) && String(describing: self[area.first!]) == String(describing: LightBattleShipsObject.battleShipTop) && String(describing: self[area.last!]) == String(describing: LightBattleShipsObject.battleShipBottom)) &&
                [Int](1..<area.count - 1).testAll({ String(describing: self[area[$0]]) == String(describing: LightBattleShipsObject.battleShipMiddle) }) else { isSolved = false; continue }
            for p in area {
                for os in LightBattleShipsGame.offset2 {
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
