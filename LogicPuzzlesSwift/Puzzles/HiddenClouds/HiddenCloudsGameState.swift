//
//  HiddenCloudsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HiddenCloudsGameState: GridGameState<HiddenCloudsGameMove> {
    var game: HiddenCloudsGame {
        get { getGame() as! HiddenCloudsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { HiddenCloudsDocument.sharedInstance }
    var objArray = [HiddenCloudsObject]()
    var pos2state = [Position: HintState]()

    override func copy() -> HiddenCloudsGameState {
        let v = HiddenCloudsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: HiddenCloudsGameState) -> HiddenCloudsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: HiddenCloudsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<HiddenCloudsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> HiddenCloudsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> HiddenCloudsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout HiddenCloudsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout HiddenCloudsGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: HiddenCloudsObject) -> HiddenCloudsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .cloud()
            case .cloud:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .cloud() : .empty
            default: return o
            }
        }
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/Hidden Clouds

        Summary
        Hide and Seek in the sky

        Description
        1. Try to find the clouds.
        2. Clouds have a square form (even of one single tile) and can't touch
           each other horizontally or vertically.
        3. Clouds of the same size cannot see each other horizontally or vertically,
           that is, there must be other Clouds between them
           (horizontally or vertically).
        4. Numbers indicate the total number of clouds tiles in the tile itself
           and in the four tiles around it (up down left right)
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] {
                    self[r, c] = .empty
                }
            }
        }
        // 2. Clouds have a square form (even of one single tile) and can't touch
        //    each other horizontally or vertically.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].toString() == "cloud" else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in ChocolateGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let cloud = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in cloud {
                if r2 < p.row { r2 = p.row }
                if r1 > p.row { r1 = p.row }
                if c2 < p.col { c2 = p.col }
                if c1 > p.col { c1 = p.col }
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1
            let s: AllowedObjectState = rs * cs == cloud.count ? .normal : .error
            if s != .normal { isSolved = false }
            for p in cloud { self[p] = .cloud(state: s) }
        }
        // 4. Numbers indicate the total number of clouds tiles in the tile itself
        //    and in the four tiles around it (up down left right)
        for (p, n2) in game.pos2hint {
            let rng = HiddenCloudsGame.offset2.map { p + $0 }.filter { isValid(p: $0) }
            let n1 = rng.filter { self[$0].toString() == "cloud" }.count
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s != .complete { isSolved = false }
            pos2state[p] = s
            guard allowedObjectsOnly && s != .normal else {continue}
            let empties = rng.filter { self[$0].toString() == "empty" }
            for p in empties { self[p] = .forbidden }
        }
    }
}
