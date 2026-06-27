//
//  ScissorsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ScissorsGameState: GridGameState<ScissorsGameMove> {
    var game: ScissorsGame {
        get { getGame() as! ScissorsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ScissorsDocument.sharedInstance }
    var objArray = [Character]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ScissorsGameState {
        let v = ScissorsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ScissorsGameState) -> ScissorsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ScissorsGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout ScissorsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ScissorsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case " ": ScissorsGame.PUZ_BACK_SLASH
        case ScissorsGame.PUZ_BACK_SLASH: ScissorsGame.PUZ_FRONT_SLASH
        case ScissorsGame.PUZ_FRONT_SLASH: " "
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 1/Scissors

        Summary
        Tailor's puzzle

        Description
        1. Cut the board into patches.
        2. Each patch should contain the numbers 1 to N exactly once (N being the highest number on the board).
        3. Each patch should end on the border.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [ScissorsPosition: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case ScissorsGame.PUZ_BACK_SLASH:
                    let (sp1, sp2) = (ScissorsPosition(p: p, n: 3), ScissorsPosition(p: p, n: 12))
                    pos2node[sp1] = g.addNode(sp1.description)
                    pos2node[sp2] = g.addNode(sp2.description)
                case ScissorsGame.PUZ_FRONT_SLASH:
                    let (sp1, sp2) = (ScissorsPosition(p: p, n: 6), ScissorsPosition(p: p, n: 9))
                    pos2node[sp1] = g.addNode(sp1.description)
                    pos2node[sp2] = g.addNode(sp2.description)
                default:
                    let sp1 = ScissorsPosition(p: p, n: 15)
                    pos2node[sp1] = g.addNode(sp1.description)
                }
            }
        }
        for (sp, node) in pos2node {
            for i in 0..<4 {
                guard sp.n & (1 << i) != 0 else {continue}
                let p2 = sp.p + ScissorsGame.offset[i], j = (i + 2) % 4
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
