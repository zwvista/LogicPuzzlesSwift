//
//  ProofOfQuiltGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ProofOfQuiltGameState: GridGameState<ProofOfQuiltGameMove> {
    var game: ProofOfQuiltGame {
        get { getGame() as! ProofOfQuiltGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ProofOfQuiltDocument.sharedInstance }
    var objArray = [ProofOfQuiltObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ProofOfQuiltGameState {
        let v = ProofOfQuiltGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ProofOfQuiltGameState) -> ProofOfQuiltGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ProofOfQuiltGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> ProofOfQuiltObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ProofOfQuiltObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ProofOfQuiltGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ProofOfQuiltGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .triangleA
        case .triangleA: .triangleB
        case .triangleB: .triangleD
        case .triangleD: .triangleC
        case .triangleC: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .triangleA : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 8/Proof of Quilt

        Summary
        Quilt the board, following the hints

        Description
         1. The goal is to place triangles in some cells in the end generating a pattern
            similar to a Quilt.
         2. The numbered tiles tell you how many triangles share an edge with it,
            horizontally and vertically
         3, For example, if a tile says 4, it has triangles all around it.
         4. If a tile says 1, it has only one triangle somewhere.
         5. Some tiles will remain blank and will form, along with the triangles, rectangles
            and squares.
         6. These can be tilted by 45 degrees.
         7. Some other tiles are filled but contain no number. These and the hints are
            the only tiles that can be completely filled.
         8. Rectangles or squares can't touch orthogonally, but can touch diagonally
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        var triangleAs = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .triangleA:
                    triangleAs.append(p)
                default:
                    break
                }
            }
        }
        for (p, n2) in game.pos2hint {
            let area = ProofOfQuiltGame.offset.map { p + $0 }.filter { isValid(p: $0) }
            let n1 = area.count { self[$0].isTriangle }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s != .complete { isSolved = false }
            pos2state[p] = s
            if allowedObjectsOnly && s != .normal {
                for p2 in area where self[p2] == .empty || self[p2] == .marker {
                    self[p2] = .forbidden
                }
            }
        }
        guard isSolved else {return}
        var allPositions = game.allPositions
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].isBlank else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in ProofOfQuiltGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let blanks = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in blanks {
                if r2 < p.row { r2 = p.row }
                if r1 > p.row { r1 = p.row }
                if c2 < p.col { c2 = p.col }
                if c1 > p.col { c1 = p.col }
                allPositions.remove(p)
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1
            if rs * cs != blanks.count { isSolved = false; return }
        }
        outer: while !triangleAs.isEmpty {
            let (r, c) = triangleAs[0].destructured
            for o in game.patterns {
                let p0 = Position(r, c - o.j + 1)
                let p1 = Position(r + o.j + o.k - 1, c + o.k)
                if isValid(p: p0) && isValid(p: p1) && (o.pattern.allSatisfy { (dp, o2) in
                    self[p0 + dp] == o2
                }) {
                    let area = o.pattern.map { p0 + $0.key }
                    for p2 in area {
                        allPositions.remove(p2)
                        triangleAs.removeAll(p2)
                    }
                    continue outer
                }
            }
            isSolved = false; return
        }
        if !allPositions.isEmpty { isSolved = false }
    }
}
