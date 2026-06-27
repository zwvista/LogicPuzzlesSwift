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
    var objArray = [Character]()
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
    
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ProofOfQuiltGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ProofOfQuiltGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case " ": ProofOfQuiltGame.PUZ_BACK_SLASH
        case ProofOfQuiltGame.PUZ_BACK_SLASH: ProofOfQuiltGame.PUZ_FRONT_SLASH
        case ProofOfQuiltGame.PUZ_FRONT_SLASH: " "
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
        isSolved = true
        let g = Graph()
        var pos2node = [ProofOfQuiltPosition: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case ProofOfQuiltGame.PUZ_BACK_SLASH:
                    let (sp1, sp2) = (ProofOfQuiltPosition(p: p, n: 3), ProofOfQuiltPosition(p: p, n: 12))
                    pos2node[sp1] = g.addNode(sp1.description)
                    pos2node[sp2] = g.addNode(sp2.description)
                case ProofOfQuiltGame.PUZ_FRONT_SLASH:
                    let (sp1, sp2) = (ProofOfQuiltPosition(p: p, n: 6), ProofOfQuiltPosition(p: p, n: 9))
                    pos2node[sp1] = g.addNode(sp1.description)
                    pos2node[sp2] = g.addNode(sp2.description)
                default:
                    let sp1 = ProofOfQuiltPosition(p: p, n: 15)
                    pos2node[sp1] = g.addNode(sp1.description)
                }
            }
        }
        for (sp, node) in pos2node {
            for i in 0..<4 {
                guard sp.n & (1 << i) != 0 else {continue}
                let p2 = sp.p + ProofOfQuiltGame.offset[i], j = (i + 2) % 4
                guard let sp2 = (pos2node.keys.first { $0.p == p2 && $0.n & (1 << j) != 0 }) else {continue}
                g.addEdge(node, neighbor: pos2node[sp2]!)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }.filter { $0.n == 15 }.map { $0.p }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            var num2rng = [Character: [Position]]()
            for p in area {
                let ch = self[p]
                if ch.isNumber { num2rng[ch, default:[]].append(p) }
            }
            let n = num2rng.values.first?.count ?? 0
            let hasNumbers = num2rng.keys.sorted() == game.numbers && num2rng.allSatisfy { $1.count == n }
            let s: HintState = !hasNumbers ? .error : n == 1 ? .complete : .normal
            if s != .complete { isSolved = false }
            for p in area { pos2state[p] = s }
        }
    }
}
