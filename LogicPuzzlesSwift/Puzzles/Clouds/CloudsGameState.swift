//
//  CloudsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CloudsGameState: GridGameState, CloudsMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: CloudsGame {
        get {return getGame() as! CloudsGame}
        set {setGame(game: newValue)}
    }
    var objArray = [CloudsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> CloudsGameState {
        let v = CloudsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CloudsGameState) -> CloudsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: CloudsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CloudsObject>(repeating: CloudsObject(), count: rows * cols)
        for p in game.pos2cloud {
            self[p] = .cloud
        }
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> CloudsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> CloudsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout CloudsGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && !game.pos2cloud.contains(p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout CloudsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: CloudsObject) -> CloudsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .cloud
            case .cloud:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .cloud : .empty
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
        iOS Game: Logic Games/Puzzle Set 5/Clouds

        Summary
        Weather Radar Report

        Description
        1. You must find Clouds in the sky.
        2. The hints on the borders tell you how many tiles are covered by Clouds
           in that row or column.
        3. Clouds only appear in rectangular or square areas. Furthermore, their
           width and height is always at least two tiles wide.
        4. Clouds can't touch between themselves, not even diagonally. 
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if self[r, c] == .forbidden {self[r, c] = .empty}
            }
        }
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if self[r, c] == .cloud {n1 += 1}
            }
            row2state[r] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if self[r, c] == .cloud {n1 += 1}
            }
            col2state[c] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        for r in 0..<rows {
            for c in 0..<cols {
                switch self[r, c] {
                case .empty, .marker:
                    if allowedObjectsOnly && (row2state[r] != .normal || col2state[c] != .normal) {self[r, c] = .forbidden}
                default:
                    break
                }
            }
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] == .cloud else {continue}
                let node = g.addNode(p.description)
                pos2node[p] = node
            }
        }
        for (p, node) in pos2node {
            for os in CloudsGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            let area = pos2node.filter({(p, _) in nodesExplored.contains(p.description)}).map{$0.0}
            pos2node = pos2node.filter({(p, _) in !nodesExplored.contains(p.description)})
            for p in area {
                if r2 < p.row {r2 = p.row}
                if r1 > p.row {r1 = p.row}
                if c2 < p.col {c2 = p.col}
                if c1 > p.col {c1 = p.col}
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1
            if !(rs >= 2 && cs >= 2 && rs * cs == nodesExplored.count) {
                isSolved = false
                return
            }
        }
    }
}
