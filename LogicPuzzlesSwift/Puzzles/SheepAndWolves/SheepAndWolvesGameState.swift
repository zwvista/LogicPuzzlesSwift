//
//  SheepAndWolvesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SheepAndWolvesGameState: GridGameState<SheepAndWolvesGameMove> {
    var game: SheepAndWolvesGame {
        get { getGame() as! SheepAndWolvesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SheepAndWolvesDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> SheepAndWolvesGameState {
        let v = SheepAndWolvesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SheepAndWolvesGameState) -> SheepAndWolvesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SheepAndWolvesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> GridDotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    private func isValidMove(move: inout SheepAndWolvesGameMove) -> Bool {
        !(move.p.row == rows - 1 && move.dir == 2 ||
            move.p.col == cols - 1 && move.dir == 1)
    }
    
    override func setObject(move: inout SheepAndWolvesGameMove) -> GameOperationType {
        guard isValidMove(move: &move) else { return .invalid }
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let p = move.p
        let dir = move.dir, dir2 = (dir + 2) % 4
        f(o1: &self[p][dir], o2: &self[p + SheepAndWolvesGame.offset[dir]][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout SheepAndWolvesGameMove) -> GameOperationType {
        guard isValidMove(move: &move) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[move.p][move.dir]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .line
        case .line: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .line : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 12/Sheep & Wolves

        Summary
        Where's a dog when you need one?

        Description
        1. Plays like SlitherLink:
        2. Draw a single looping path with the aid of the numbered hints. The
           path cannot have branches or cross itself.
        3. Each number tells you on how many of its four sides are touched by
           the path.
        4. With this added rule:
        5. In the end all the sheep must be corralled inside the loop, while
           all the wolves must be outside.
    */
    private func updateIsSolved() {
        isSolved = true
        // 3. Each number tells you on how many of its four sides are touched by
        //    the path.
        for (p, n2) in game.pos2hint {
            var n1 = 0
            for i in 0..<4 {
                if self[p + SheepAndWolvesGame.offset2[i]][SheepAndWolvesGame.dirs[i]] == .line { n1 += 1 }
            }
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].filter { $0 == .line }.count
                switch n {
                case 0:
                    continue
                case 2:
                    pos2node[p] = g.addNode(p.description)
                default:
                    // 2. The path cannot have branches or cross itself.
                    isSolved = false
                    return
                }
            }
        }
        for p in pos2node.keys {
            let dotObj = self[p]
            for i in 0..<4 {
                guard dotObj[i] == .line else {continue}
                let p2 = p + SheepAndWolvesGame.offset[i]
                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        // 2. Draw a single looping path with the aid of the numbered hints.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        guard isSolved else {return}
        let sheep0 = game.sheep[0]
        let d = 0
        var n = 0
        let os = SheepAndWolvesGame.offset[d]
        var p2 = sheep0
        while isValid(p: p2) {
            if self[p2 + SheepAndWolvesGame.offset2[d]][SheepAndWolvesGame.dirs[d]] == .line { n += 1 }
            p2 += os
        }
        if n % 2 == 0 { isSolved = false }
        guard isSolved else {return}
        // 5. In the end all the sheep must be corralled inside the loop, while
        //    all the wolves must be outside.
        let g2 = Graph()
        var pos2node2 = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                pos2node2[p] = g2.addNode(p.description)
            }
        }
        for (p, node) in pos2node2 {
            for i in 0..<4 {
                guard self[p + SheepAndWolvesGame.offset2[i]][SheepAndWolvesGame.dirs[i]] != .line else {continue}
                let p2 = p + SheepAndWolvesGame.offset[i]
                guard let node2 = pos2node2[p2] else {continue}
                g2.addEdge(node, neighbor: node2)
            }
        }
        let nodesExplored2 = breadthFirstSearch(g2, source: pos2node2[sheep0]!)
        if !game.sheep.allSatisfy({ nodesExplored2.contains($0.description) }) || game.wolves.contains(where: { nodesExplored2.contains($0.description) }) { isSolved = false }
    }
}
