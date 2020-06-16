//
//  DigitalBattleShipsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DigitalBattleShipsGameState: GridGameState<DigitalBattleShipsGameMove> {
    var game: DigitalBattleShipsGame {
        get { getGame() as! DigitalBattleShipsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { DigitalBattleShipsDocument.sharedInstance }
    var objArray = [DigitalBattleShipsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> DigitalBattleShipsGameState {
        let v = DigitalBattleShipsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: DigitalBattleShipsGameState) -> DigitalBattleShipsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: DigitalBattleShipsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<DigitalBattleShipsObject>(repeating: DigitalBattleShipsObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> DigitalBattleShipsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> DigitalBattleShipsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout DigitalBattleShipsGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout DigitalBattleShipsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: DigitalBattleShipsObject) -> DigitalBattleShipsObject {
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
        iOS Game: Logic Games/Puzzle Set 13/Digital Battle Ships

        Summary
        Please divert your course 12+1+2 to avoid collision

        Description
        1. Play like Solo Battle Ships, with a difference.
        2. Each number on the outer board tells you the SUM of the ship or
           ship pieces you're seeing in that row or column.
        3. A ship or ship piece is worth the number it occupies on the board.
        4. Standard rules apply: a ship or piece of ship can't touch another,
           not even diagonally.
        5. In each puzzle there are
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
        // 2. Each number on the outer board tells you the SUM of the ship or
        // ship pieces you're seeing in that row.
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                switch self[r, c] {
                case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                    // 3. A ship or ship piece is worth the number it occupies on the board.
                    n1 += game[r, c]
                default:
                    break
                }
            }
            row2state[r] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
        }
        // 2. Each number on the outer board tells you the SUM of the ship or
        // ship pieces you're seeing in that column.
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                switch self[r, c] {
                case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                    // 3. A ship or ship piece is worth the number it occupies on the board.
                    n1 += game[r, c]
                default:
                    break
                }
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
                let p2 = p + DigitalBattleShipsGame.offset[i * 2]
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        var shipNumbers = Array<Int>(repeating: 0, count: 5)
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }.sorted()
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
            guard area.count == 1 && self[area.first!] == .battleShipUnit || 2...4 ~= area.count && (
                area.testAll({ $0.row == area.first!.row }) && self[area.first!] == .battleShipLeft && self[area.last!] == .battleShipRight ||
                area.testAll({ $0.col == area.first!.col }) && self[area.first!] == .battleShipTop && self[area.last!] == .battleShipBottom) &&
                [Int](1..<area.count - 1).testAll({ self[area[$0]] == .battleShipMiddle }) else { isSolved = false; continue }
            for p in area {
                for os in DigitalBattleShipsGame.offset {
                    // 4. A ship or piece of ship can't touch another, not even diagonally.
                    let p2 = p + os
                    if !self.isValid(p: p2) || area.contains(p2) {continue}
                    let o = self[p2]
                    if !(o == .empty || o == .forbidden || o == .marker) {
                        isSolved = false
                    } else if allowedObjectsOnly {
                        self[p2] = .forbidden
                    }
                }
            }
            shipNumbers[area.count] += 1
        }
        // 5. In each puzzle there are
        //    1 Aircraft Carrier (4 squares)
        //    2 Destroyers (3 squares)
        //    3 Submarines (2 squares)
        //    4 Patrol boats (1 square)
        if shipNumbers != [0, 4, 3, 2, 1] { isSolved = false }
    }
}
