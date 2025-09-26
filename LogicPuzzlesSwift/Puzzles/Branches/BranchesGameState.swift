//
//  BranchesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BranchesGameState: GridGameState<BranchesGameMove> {
    var game: BranchesGame {
        get { getGame() as! BranchesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { BranchesDocument.sharedInstance }
    var objArray = [BranchesObject]()
    
    override func copy() -> BranchesGameState {
        let v = BranchesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BranchesGameState) -> BranchesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: BranchesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BranchesObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> BranchesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> BranchesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout BranchesGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return false }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout BranchesGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: BranchesObject) -> BranchesObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .up
            case .up:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .horizontal
            case .horizontal:
                return .vertical
            case .vertical:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .up : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 2/Branches

        Summary
        Fill the board with Branches departing from the numbers

        Description
        1. In Branches you must fill the board with straight horizontal and
           vertical lines(Branches) that stem from each number.
        2. The number itself tells you how many tiles its Branches fill up.
           The tile with the number doesn't count.
        3. There can't be blank tiles and Branches can't overlap, nor run over
           the numbers. Moreover Branches must be in a single straight line
           and can't make corners.
    */
    private func updateIsSolved() {
//        isSolved = true
//        var chars = ""
//        // 1. The goal is to shade squares so that a number appears only once in a
//        // row.
//        for r in 0..<rows {
//            chars = ""
//            row2hint[r] = ""
//            for c in 0..<cols {
//                let p = Position(r, c)
//                guard self[p] != .darken else {continue}
//                let ch = game[p]
//                if chars.contains(String(ch)) {
//                    isSolved = false
//                    row2hint[r].append(ch)
//                } else {
//                    chars.append(ch)
//                }
//            }
//        }
//        // 1. The goal is to shade squares so that a number appears only once in a
//        // column.
//        for c in 0..<cols {
//            chars = ""
//            col2hint[c] = ""
//            for r in 0..<rows {
//                let p = Position(r, c)
//                guard self[p] != .darken else {continue}
//                let ch = game[p]
//                if chars.contains(String(ch)) {
//                    isSolved = false
//                    col2hint[c].append(ch)
//                } else {
//                    chars.append(ch)
//                }
//            }
//        }
//        guard isSolved else {return}
//        let g = Graph()
//        var pos2node = [Position: Node]()
//        var rngDarken = [Position]()
//        for r in 0..<rows {
//            for c in 0..<cols {
//                let p = Position(r, c)
//                switch self[p] {
//                case .darken:
//                    rngDarken.append(p)
//                default:
//                    pos2node[p] = g.addNode(p.description)
//                }
//            }
//        }
//        // 2. While doing that, you must take care that shaded squares don't touch
//        // horizontally or vertically between them.
//        for p in rngDarken {
//            for os in BranchesGame.offset {
//                let p2 = p + os
//                guard !rngDarken.contains(p2) else { isSolved = false; return }
//            }
//        }
//        for (p, node) in pos2node {
//            for os in BranchesGame.offset {
//                let p2 = p + os
//                guard let node2 = pos2node[p2] else {continue}
//                g.addEdge(node, neighbor: node2)
//            }
//        }
//        // 3. In the end all the un-shaded squares must form a single continuous area.
//        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
//        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
