//
//  MineShipsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MineShipsGameState: GridGameState<MineShipsGameMove> {
    var game: MineShipsGame {
        get { getGame() as! MineShipsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MineShipsDocument.sharedInstance }
    var objArray = [MineShipsObject]()
    
    override func copy() -> MineShipsGameState {
        let v = MineShipsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MineShipsGameState) -> MineShipsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MineShipsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MineShipsObject>(repeating: MineShipsObject(), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MineShipsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MineShipsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MineShipsGameMove) -> GameOperationType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return .invalid }
        guard String(describing: o1) != String(describing: o2) else { return .invalid }
        self[p] = o2
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout MineShipsGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: MineShipsObject) -> MineShipsObject {
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
        guard isValid(p: p) else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 8/Mine Ships

        Summary
        Warning! Naval Mines in the water!

        Description
        1. There are actually no mines in the water, but this is a mix between
           Minesweeper and Battle Ships.
        2. You must find the same set of ships like 'Battle Ships'
           (1*4, 2*3, 3*2, 4*1).
        3. However this time the hints are given in the same form as 'Minesweeper',
           where a number tells you how many pieces of ship are around it.
        4. Usual Battle Ships rules apply!
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] { self[r, c] = .empty }
            }
        }
        // 3. A number tells you how many pieces of ship are around it.
        for (p, n2) in game.pos2hint {
            var n1 = 0
            var rng = [Position]()
            for os in MineShipsGame.offset {
                let p2 = p + os
                guard game.isValid(p: p2) else {continue}
                switch self[p2] {
                case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                    n1 += 1
                case .empty:
                    rng.append(p2)
                default:
                    break
                }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
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
                let p2 = p + MineShipsGame.offset[i * 2]
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        var shipNumbers = Array<Int>(repeating: 0, count: 5)
        while pos2node.count > 0 {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }.sorted()
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            guard area.count == 1 && String(describing: self[area.first!]) == String(describing: MineShipsObject.battleShipUnit) || 2...4 ~= area.count && (
                area.testAll({ $0.row == area.first!.row }) && String(describing: self[area.first!]) == String(describing: MineShipsObject.battleShipLeft) && String(describing: self[area.last!]) == String(describing: MineShipsObject.battleShipRight) ||
                area.testAll({ $0.col == area.first!.col }) && String(describing: self[area.first!]) == String(describing: MineShipsObject.battleShipTop) && String(describing: self[area.last!]) == String(describing: MineShipsObject.battleShipBottom)) &&
                [Int](1..<area.count - 1).testAll({ String(describing: self[area[$0]]) == String(describing: MineShipsObject.battleShipMiddle) }) else { isSolved = false; continue }
            for p in area {
                for os in MineShipsGame.offset {
                    // A ship or piece of ship can't touch another, not even diagonally.
                    let p2 = p + os
                    if !self.isValid(p: p2) || area.contains(p2) {continue}
                    switch self[p2] {
                    case .empty, .marker:
                        if allowedObjectsOnly { self[p2] = .forbidden }
                    case .forbidden, .hint:
                        break
                    default:
                        isSolved = false
                    }
                }
            }
            shipNumbers[area.count] += 1
        }
        // In each puzzle there are
        //    1 Aircraft Carrier (4 squares)
        //    2 Destroyers (3 squares)
        //    3 Submarines (2 squares)
        //    4 Patrol boats (1 square)
        if shipNumbers != [0, 4, 3, 2, 1] { isSolved = false }
    }
}
