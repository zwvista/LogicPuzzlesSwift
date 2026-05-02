//
//  PlanetsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PlanetsGameState: GridGameState<PlanetsGameMove> {
    var game: PlanetsGame {
        get { getGame() as! PlanetsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PlanetsDocument.sharedInstance }
    var objArray = [PlanetsObject]()
    var pos2state = [Position: AllowedObjectState]()
    
    override func copy() -> PlanetsGameState {
        let v = PlanetsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PlanetsGameState) -> PlanetsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PlanetsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> PlanetsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PlanetsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout PlanetsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout PlanetsGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 2/Puzzle Set 1/Planets

        Summary
        Planets, Stars and Nebulas

        Description
        1. In Planets you are given an interesting Galaxy, where Suns only
           shine their light in horizontal and vertical lines.
        2. On the board you can see the Planets of this Galaxy. Each Planet
           is lit on some side (or not lit at all).
        3. You should place one Sun on each row and column, according to how
           the Planets are lit.
        4. You should also place one Nebula on each row and column.
        5. Nebulas block sunlight, so if there is a Nebula between a Sun and
           a Planet, the Planet won't be lit.
        6. Finally, Planets block sunlight too. So if there is a Planet
           between a Sun and another Planet, the further Planet won't be lit
           by that Sun.
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
            for os in PlanetsGame.offset {
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
                let os = PlanetsGame.offset[i]
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
