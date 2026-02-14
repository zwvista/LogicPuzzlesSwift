//
//  ParkingLotGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ParkingLotGameState: GridGameState<ParkingLotGameMove> {
    var game: ParkingLotGame {
        get { getGame() as! ParkingLotGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ParkingLotDocument.sharedInstance }
    var objArray = [ParkingLotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ParkingLotGameState {
        let v = ParkingLotGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ParkingLotGameState) -> ParkingLotGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ParkingLotGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ParkingLotObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> ParkingLotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ParkingLotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ParkingLotGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ParkingLotGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .left
        case .left: .right
        case .right: .horizontal
        case .horizontal: .top
        case .top: .bottom
        case .bottom: .vertical
        case .vertical: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .left : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 11/Parking Lot

        Summary
        BEEEEP BEEEEEEP !!!

        Description
        1. The board represents a parking lot seen from above.
        2. Each number identifies a car and all cars are identified by a number,
           there are no hidden cars.
        3. Cars can be regular sports cars (2*1 tiles) or limousines (3*1 tiles)
           and can be oriented horizontally or vertically.
        4. The number in itself specifies how far the car can move forward or
           backward, in tiles.
        5. For example, a car that has one tile free in front and one tile free
           in the back, would be marked with a '2'.
        6. Find all the cars !!
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .forbidden { self[p] = .empty }
            }
        }
        for (p, n2) in game.pos2hint {
            var n1 = 0
            var rng = [Position]()
            for os  in ParkingLotGame.offset2 {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                switch self[p2] {
                case .empty, .marker:
                    rng.append(os)
                case .wall:
                    n1 += 1
                default:
                    break
                }
            }
            // 3. The number tells you how many pieces (squares) of wall it touches.
            // 4. So the number can go from 0 (no walls around the tower) to 4 (tower
            // entirely surrounded by walls).
            // 5. Board borders don't count as walls, so there you'll have two walls
            // at most (or one in corners).
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
            if s != .normal && allowedObjectsOnly {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
        if !isSolved {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] != .wall { pos2node[p] = g.addNode(p.description) }
            }
        }
        for (p, node) in pos2node {
            for os in ParkingLotGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(node, neighbor: node2)
                }
            }
        }
        // 6. To facilitate movement in the castle, the Bailey must have a single
        // continuous area (Garden).
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
