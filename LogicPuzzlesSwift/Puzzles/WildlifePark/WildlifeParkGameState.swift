//
//  WildlifeParkGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class WildlifeParkGameState: GridGameState<WildlifeParkGameMove> {
    var game: WildlifeParkGame {
        get { getGame() as! WildlifeParkGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { WildlifeParkDocument.sharedInstance }
    var objArray = [GridDotObject]()
    
    override func copy() -> WildlifeParkGameState {
        let v = WildlifeParkGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: WildlifeParkGameState) -> WildlifeParkGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: WildlifeParkGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
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
    
    override func setObject(move: inout WildlifeParkGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + WildlifeParkGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout WildlifeParkGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            default:
                return o
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 1/Wildlife Park

        Summary
        One rises, the other falls

        Description
        1. At the last game of Wildlife Football, Lemurs accused Giraffes of cheating,
           Monkeys ran away with the coin after the toss and Lions ate the ball.
        2. So you're given the task to raise some fencing between the different species,
           while spirits cool down.
        3. Fences should encompass at least one animal of a certain species, and all
           animals of a certain species must be in the same enclosure.
        4. There can't be empty enclosures.
        5. Where three or four fences meet, a fence post is put in place. On the Park
           all posts are already marked with a dot.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        func isBorder(_ p: Position) -> Bool {
            return p.row == 0 || p.col == 0 || p.row == rows - 1 || p.col == cols - 1
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let isB = isBorder(p)
                var dirs = (0..<4).filter { self[p][$0] == .line }
                if !{
                    switch dirs.count {
                    case 0:
                        return true
                    case 2:
                        // 4. Lines only turn at posts (dots).
                        // 6. Not all posts must be used.
                        return isB || dirs[1] - dirs[0] == 2 || game.posts.contains(p)
                    case 3:
                        // 3. The lines (fencing) of the enclosures start and end on the edges of the
                        //    grid.
                        return isB
                    case 4:
                        // 5. Lines can cross each other except posts (dots).
                        return !game.posts.contains(p)
                    default:
                        return false
                    }
                }() { isSolved = false; return }
                if isB {
                    dirs.removeAll { isBorder(p + WildlifeParkGame.offset[$0]) }
                }
                if !dirs.isEmpty {
                    pos2dirs[p] = dirs
                }
            }
        }
        // Check the lines
        while !pos2dirs.isEmpty {
            guard let p = (pos2dirs.first { $1.count == 1 }?.key) else { isSolved = false; return }
            var p2 = p, n = -1
            while true {
            guard var dirs = pos2dirs[p2] else { isSolved = false; return }
                if dirs.count == 4 {
                    dirs.removeAll(n)
                    dirs.removeAll((n + 2) % 4)
                    pos2dirs[p2] = dirs
                } else {
                    pos2dirs.removeValue(forKey: p2)
                    if p2 != p && dirs.count == 1 {break}
                    n = dirs.first { ($0 + 2) % 4 != n }!
                }
                p2 += WildlifeParkGame.offset[n]
            }
        }

        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
            }
        }
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for i in 0..<4 {
                    guard self[p + WildlifeParkGame.offset2[i]][WildlifeParkGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + WildlifeParkGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rngWolves = area.filter { game.wolves.contains($0) }
            let rngSheep = area.filter { game.sheep.contains($0) }
            // 2. Each enclosure must contain either sheep or wolves (but not both) and
            //    must not be empty.
            guard rngSheep.isEmpty != rngWolves.isEmpty else { isSolved = false; return }
        }
    }
}
