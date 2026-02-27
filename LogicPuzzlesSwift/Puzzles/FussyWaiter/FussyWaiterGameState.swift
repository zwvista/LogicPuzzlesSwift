//
//  FussyWaiterGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FussyWaiterGameState: GridGameState<FussyWaiterGameMove> {
    var game: FussyWaiterGame {
        get { getGame() as! FussyWaiterGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FussyWaiterDocument.sharedInstance }
    var objArray = [FussyWaiterObject]()
    
    override func copy() -> FussyWaiterGameState {
        let v = FussyWaiterGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FussyWaiterGameState) -> FussyWaiterGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FussyWaiterGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> FussyWaiterObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FussyWaiterObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout FussyWaiterGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), case .empty = game[p], String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FussyWaiterGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), case .empty = game[p] else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .flower()
        case .flower: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .flower() : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 15/Fussy Waiter

        Summary
        Won't give you what you asked for

        Description
        1. This restaurant has a peculiar waiter. Priding himself on a math
           degree, he is very fussy about how you order.
        2. Respecting university nutrition balance, he only accepts unique
           pairings of food and drinks.
        3. Thus, a type of food can be ordered along with the same drink only
           on a single table.
        4. Moreover, touting sudoku nutrition, he also maintains that each row
           and column of tables must have each food and drinks represented
           exactly once.
        5. He is indeed, very fussy.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .flower:
                    self[p] = .flower()
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            for os in FussyWaiterGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 2. More exactly, you have to join the existing flowers by adding more of
        // them, creating a single path of flowers touching horizontally or
        // vertically.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        
        var flowers = [Position]()
        // 3. At the same time, you can't line up horizontally or vertically more
        // than 3 flowers (thus Forbidden Four).
        func invalidFlowers() -> Bool {
            flowers.count > 3
        }
        func checkFlowers() {
            if invalidFlowers() {
                isSolved = false
                for p in flowers {
                    self[p] = .flower(state: .error)
                }
            }
            flowers.removeAll()
        }
        func checkForbidden(p: Position, indexes: [Int]) {
            guard allowedObjectsOnly else {return}
            for i in indexes {
                let os = FussyWaiterGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) {
                    guard case .flower = self[p2] else {break}
                    flowers.append(p2)
                    p2 += os
                }
            }
            if invalidFlowers() { self[p] = .forbidden }
            flowers.removeAll()
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .flower:
                    flowers.append(p)
                case .empty, .marker:
                    checkFlowers()
                    checkForbidden(p: p, indexes: [1,3])
                default:
                    checkFlowers()
                }
            }
            checkFlowers()
        }
        for c in 0..<cols {
            for r in 0..<rows {
                let p = Position(r, c)
                switch self[p] {
                case .flower:
                    flowers.append(p)
                case .empty, .marker:
                    checkFlowers()
                    checkForbidden(p: p, indexes: [0,2])
                default:
                    checkFlowers()
                }
            }
            checkFlowers()
        }
    }
}
