//
//  LightBattleShipsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightBattleShipsGameState: GridGameState, LightBattleShipsMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: LightBattleShipsGame {
        get {return getGame() as! LightBattleShipsGame}
        set {setGame(game: newValue)}
    }
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
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> LightBattleShipsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout LightBattleShipsGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 {return false}
        guard String(describing: o1) != String(describing: o2) else {return false}
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
        guard isValid(p: p) else {return false}
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
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] {self[r, c] = .empty}
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor(isHint: Bool) -> Bool {
                    for os in LightBattleShipsGame.offset {
                        let p2 = p + os
                        guard isValid(p: p2) else {continue}
                        switch self[p2] {
                        case .hint:
                            if !isHint {return true}
                        case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                            if isHint {return true}
                        default:
                            break
                        }
                    }
                    return false
                }
                switch self[p] {
                case .hint:
                    self[p] = .hint(state: !hasNeighbor(isHint: true) ? .normal : .error)
                case .empty, .marker:
                    guard allowedObjectsOnly && hasNeighbor(isHint: false) else {continue}
                    self[p] = .forbidden
                default:
                    break
                }
            }
        }
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
            if case let .hint(state) = self[p], state != .error {self[p] = .hint(state: s)}
            if s != .complete {
                isSolved = false
            } else if allowedObjectsOnly {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
        guard isSolved else {return}
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
            let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
            let area = pos2node.filter({(p, _) in nodesExplored.contains(p.description)}).map({$0.0}).sorted()
            pos2node = pos2node.filter({(p, _) in !nodesExplored.contains(p.description)})
            func f(os: Position, objTopLeft: LightBattleShipsObject, objBottomRight: LightBattleShipsObject) -> Bool {
                return String(describing: self[area.first!]) == String(describing: objTopLeft) && String(describing: self[area.last!]) == String(describing: objBottomRight) &&
                    [Int](1..<area.count - 1).testAll({String(describing: self[area[$0]]) == String(describing: LightBattleShipsObject.battleShipMiddle)}) &&
                    [Int](1..<area.count).testAll({area[$0] - area[$0 - 1] == os})
            }
            guard (area.count == 1 && String(describing: self[area.first!]) == String(describing: LightBattleShipsObject.battleShipUnit) || area.count > 1 && area.count < 5 && (
                area.testAll({$0.row == area.first!.row}) && f(os: Position(0, 1), objTopLeft: .battleShipLeft, objBottomRight: .battleShipRight) ||
                    area.testAll({$0.col == area.first!.col}) && f(os: Position(1, 0), objTopLeft: LightBattleShipsObject.battleShipTop, objBottomRight: LightBattleShipsObject.battleShipBottom))) && LightBattleShipsGame.offset2.testAll({os in area.testAll({
                        let p2 = $0 + os
                        if !self.isValid(p: p2) {return true}
                        switch self[p2] {
                        case .empty, .forbidden, .marker, .hint:
                            return true
                        default:
                            return false
                        }
                    })}) else {isSolved = false; return}
            shipNumbers[area.count] += 1
        }
        if shipNumbers != [0, 4, 3, 2, 1] {isSolved = false}
    }
}
