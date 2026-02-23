//
//  FlowerOMinoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FlowerOMinoGameState: GridGameState<FlowerOMinoGameMove> {
    var game: FlowerOMinoGame {
        get { getGame() as! FlowerOMinoGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FlowerOMinoDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: AllowedObjectState]()
    var gardens = [[Position]]()
    
    override func copy() -> FlowerOMinoGameState {
        let v = FlowerOMinoGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FlowerOMinoGameState) -> FlowerOMinoGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FlowerOMinoGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.dots.objArray
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
    
    override func setObject(move: inout FlowerOMinoGameMove) -> GameOperationType {
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
        let dir = move.dir, dir2 = (dir + 2) % 4
        let p = move.p, p2 = p + FlowerOMinoGame.offset[dir]
        guard isValid(p: p2) && game.dots[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout FlowerOMinoGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 4/Puzzle Set 1/Flower-O-Mino

        Summary
        Don't tread On flowers, Often.

        Description
        1. You are a gardener. you've been employed by a sour weird lady.
        2. This lady, after years of having her garden grow wild with flowers
           and without enclosures, decided that those are way too many flowers
           and too few enclosures.
        3. So now being an avid fan of Tetris, she asked you to divide the garden
           in many Tetris shaped mini-gardens.
        4. And while doing that they HAVE to tread, destroy and plow as many
           flowers as you can, provide you leave just the one in each Tetris
           mini-garden.
        5. Divide the board in tetrominos (4-tile pieces). Each tetromino should
           have only one flower inside it.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                guard game[p] != .hedge else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for i in 0..<4 {
                guard self[p + FlowerOMinoGame.offset2[i]][FlowerOMinoGame.dirs[i]] != .line, let node2 = pos2node[p + FlowerOMinoGame.offset[i]] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            guard area.count == 4 else { isSolved = false; continue }
            gardens.append(area)
            let n2 = 1
            let n1 = area.reduce(0) { acc, p in
                var m = 0
                let o = game[p]
                if o.hasCenter { m += 1 }
                if o.hasRight && area.contains(p + FlowerOMinoGame.offset[1]) { m += 1 }
                if o.hasBottom && area.contains(p + FlowerOMinoGame.offset[2]) { m += 1 }
                return acc + m
            }
            let s: AllowedObjectState = n1 == n2 ? .normal : .error
            for p in area { pos2state[p] = s }
            if s == .error { isSolved = false }
        }
    }
}
