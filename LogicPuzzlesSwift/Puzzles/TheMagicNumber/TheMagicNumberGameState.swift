//
//  TheMagicNumberGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TheMagicNumberGameState: GridGameState<TheMagicNumberGameMove> {
    var game: TheMagicNumberGame {
        get { getGame() as! TheMagicNumberGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TheMagicNumberDocument.sharedInstance }
    var objArray = [TheMagicNumberObject]()
    var pos2state = [Position: AllowedObjectState]()
    
    override func copy() -> TheMagicNumberGameState {
        let v = TheMagicNumberGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TheMagicNumberGameState) -> TheMagicNumberGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TheMagicNumberGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> TheMagicNumberObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TheMagicNumberObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TheMagicNumberGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TheMagicNumberGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .flower
        case .flower: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .flower : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 3/The Magic Number

        Summary
        No more, no less, you don't have to guess

        Description
        1. Fill the board with 3 different symbols.
        2. On side-6 boards there will be 2 of each on any row or column.
        3. On side-9 boards there will be 3 of each on any row or column.
        4. On side-12 boards there will be 4 of each on any row or column.
        5. When a tile has a shaded background, the symbols around it must
           be different.
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
                    pos2state[p] = .normal
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            for os in TheMagicNumberGame.offset {
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
            if flowers.count > 3 {
                isSolved = false
                for p in flowers {
                    pos2state[p] = .error
                }
            }
            flowers.removeAll()
        }
        func checkForbidden(p: Position, indexes: [Int]) {
            guard allowedObjectsOnly else {return}
            for i in indexes {
                let os = TheMagicNumberGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) {
                    guard self[p2] == .flower else {break}
                    flowers.append(p2)
                    p2 += os
                }
            }
            if flowers.count > 2 { self[p] = .forbidden }
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
