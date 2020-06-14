//
//  BattleShipsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BattleShipsGameState: GridGameState<BattleShipsGame, BattleShipsDocument, BattleShipsGameMove> {
    override var gameDocument: BattleShipsDocument { BattleShipsDocument.sharedInstance }
    var objArray = [BattleShipsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> BattleShipsGameState {
        let v = BattleShipsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BattleShipsGameState) -> BattleShipsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: BattleShipsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BattleShipsObject>(repeating: BattleShipsObject(), count: rows * cols)
        for (p, obj) in game.pos2obj {
            self[p] = obj
        }
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> BattleShipsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> BattleShipsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout BattleShipsGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game.pos2obj[p] == nil && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout BattleShipsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: BattleShipsObject) -> BattleShipsObject {
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
        iOS Game: Logic Games/Puzzle Set 1/Battle Ships

        Summary
        Play solo Battleships, with the help of the numbers on the border.

        Description
        1. Standard rules of Battleships apply, but you are guessing the other
           player ships disposition, by using the numbers on the borders.
        2. Each number tells you how many ship or ship pieces you're seeing in
           that row or column.
        3. Standard rules apply: a ship or piece of ship can't touch another,
           not even diagonally.
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
        // 2. Each number tells you how many ship or ship pieces you're seeing in that row.
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if self[r, c].isShipPiece() { n1 += 1 }
            }
            row2state[r] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
        }
        // 2. Each number tells you how many ship or ship pieces you're seeing in that column.
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if self[r, c].isShipPiece() { n1 += 1 }
            }
            col2state[c] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                switch self[r, c] {
                case .empty, .marker:
                    if allowedObjectsOnly && (row2state[r] != .normal || col2state[c] != .normal) { self[r, c] = .forbidden }
                default:
                    break
                }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[r, c].isShipPiece() {
                    let node = g.addNode(p.description)
                    pos2node[p] = node
                }
            }
        }
        for (p, node) in pos2node {
            for i in 0..<4  {
                let p2 = p + BattleShipsGame.offset[i * 2]
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        var shipNumbers = Array<Int>(repeating: 0, count: 5)
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map({ $0.0 }).sorted()
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
            guard area.count == 1 && self[area.first!] == .battleShipUnit || area.count > 1 && area.count < 5 && (
                area.testAll({ $0.row == area.first!.row }) && self[area.first!] == .battleShipLeft && self[area.last!] == .battleShipRight ||
                area.testAll({ $0.col == area.first!.col }) && self[area.first!] == .battleShipTop && self[area.last!] == .battleShipBottom) &&
                [Int](1..<area.count - 1).testAll({ self[area[$0]] == .battleShipMiddle }) else { isSolved = false; continue }
            for p in area {
                for os in BattleShipsGame.offset {
                    // 3. A ship or piece of ship can't touch another, not even diagonally.
                    let p2 = p + os
                    if !self.isValid(p: p2) || area.contains(p2) {continue}
                    if self[p2].isShipPiece() {
                        isSolved = false
                    } else if allowedObjectsOnly {
                        self[p2] = .forbidden
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
