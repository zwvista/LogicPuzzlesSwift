//
//  FloorPlanGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FloorPlanGameState: GridGameState<FloorPlanGameMove> {
    var game: FloorPlanGame {
        get { getGame() as! FloorPlanGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FloorPlanDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()

    override func copy() -> FloorPlanGameState {
        let v = FloorPlanGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FloorPlanGameState) -> FloorPlanGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FloorPlanGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }

    override func setObject(move: inout FloorPlanGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == FloorPlanGame.PUZ_EMPTY && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FloorPlanGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == FloorPlanGame.PUZ_EMPTY else { return .invalid }
        let o = self[p]
        let markerOption = MarkerOptions(rawValue: markerOption)
        move.obj =
            o == DigitalPathGame.PUZ_EMPTY ? markerOption == .markerFirst ? DigitalPathGame.PUZ_MARKER : 1 :
            o == DigitalPathGame.PUZ_MARKER ? markerOption == .markerFirst ? 1 : DigitalPathGame.PUZ_EMPTY :
            o == 4 ? markerOption == .markerLast ? DigitalPathGame.PUZ_MARKER : DigitalPathGame.PUZ_EMPTY :
            o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 1/Floor Plan

        Summary
        Blueprints to fill in

        Description
        1. The board represents a blueprint of an office floor.
        2. Cells with a number represent an office. On the floor every office is
           interconnected and can be reached by every other office.
        3. The number on a cell indicates how many offices it connects to. No two
           offices with the same number can be adjacent.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2state[p] = .normal
                if self[p] == FloorPlanGame.PUZ_FORBIDDEN {
                    self[p] = FloorPlanGame.PUZ_EMPTY
                }
            }
        }
        // 2. Cells with a number represent an office. On the floor every office is
        //    interconnected and can be reached by every other office.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n2 = self[p]
                guard n2 > 0 else {continue}
                pos2node[p] = g.addNode(p.description)
                _ = pos2state[p, default: .normal]
                // 3. The number on a cell indicates how many offices it connects to. No two
                //    offices with the same number can be adjacent.
                let rng = FloorPlanGame.offset.map { p + $0 }.filter { isValid(p: $0) }
                let rng2 = rng.filter { self[$0] == n2 }
                if !rng2.isEmpty {
                    isSolved = false
                    pos2state[p] = .error
                    for p2 in rng2 { pos2state[p2] = .error }
                }
                guard pos2state[p] != .error else {continue}
                let n1 = rng.filter { self[$0] > 0 }.count
                let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
                if s != .complete { isSolved = false }
                pos2state[p] = s
                guard allowedObjectsOnly && s != .normal else {continue}
                rng.filter { self[$0] == FloorPlanGame.PUZ_EMPTY }.forEach {
                    self[$0] = FloorPlanGame.PUZ_FORBIDDEN
                }
            }
        }
        guard isSolved else {return}
        for (p, node) in pos2node {
            for os in FloorPlanGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
