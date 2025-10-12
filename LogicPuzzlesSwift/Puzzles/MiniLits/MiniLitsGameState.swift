//
//  MiniLitsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MiniLitsAreaInfo {
    var trees = [Position]()
    var blockIndexes = Set<Int>()
    var neighborIndexes = Set<Int>()
    var triominoIndex: Int?
}

class MiniLitsGameState: GridGameState<MiniLitsGameMove> {
    var game: MiniLitsGame {
        get { getGame() as! MiniLitsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MiniLitsDocument.sharedInstance }
    var objArray = [MiniLitsObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> MiniLitsGameState {
        let v = MiniLitsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MiniLitsGameState) -> MiniLitsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: MiniLitsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MiniLitsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MiniLitsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MiniLitsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MiniLitsGameMove) -> GameChangeType {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else { return .none }
        self[p] = move.obj
        updateIsSolved()
        return .level
    }
    
    override func switchObject(move: inout MiniLitsGameMove) -> GameChangeType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: MiniLitsObject) -> MiniLitsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tree(state: .normal)
            case .tree:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tree(state: .normal) : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else { return .none }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 14/Mini-Lits

        Summary
        Lits Jr.

        Description
        1. You play the game with triominos (pieces of three squares).
        2. The board is divided into many areas. You have to place a triomino
           into each area respecting these rules:
        3. No two adjacent (touching horizontally / vertically) triominos should
           be of equal shape & orientation.
        4. All the shaded cells should form a valid Nurikabe.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .tree:
                    self[p] = .tree(state: .normal)
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
            }
        }
        for p in pos2node.keys {
            for os in MiniLitsGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(pos2node[p]!, neighbor: node2)
                }
            }
        }
        var blocks = [[Position]]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let block = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }
            blocks.append(block)
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
        }
        // 4. All the shaded cells should form a valid Nurikabe.
        if blocks.count != 1 { isSolved = false }
        // https://stackoverflow.com/questions/32921425/swift-creating-an-array-with-a-default-value-of-distinct-object-instances
        let infos = game.areas.count.range.map { _ in MiniLitsAreaInfo() }
        for i in 0..<blocks.count {
            let block = blocks[i]
            for p in block {
                let n = game.pos2area[p]!
                let info = infos[n]
                info.trees.append(p)
                info.blockIndexes.insert(i)
            }
        }
        for i in 0..<infos.count {
            let info = infos[i]
            for p in info.trees {
                for os in MiniLitsGame.offset {
                    let p2 = p + os
                    guard let index = infos.firstIndex(where: { $0.trees.contains(p2) }),
                        index != i else {continue}
                    info.neighborIndexes.insert(index)
                }
            }
        }
        func notSolved(info: MiniLitsAreaInfo) {
            isSolved = false
            for p in info.trees {
                self[p] = .tree(state: .error)
            }
        }
        for i in 0..<infos.count {
            let info = infos[i]
            let treeCount = info.trees.count
            if treeCount >= 3 && allowedObjectsOnly {
                for p in game.areas[i] {
                    switch self[p] {
                    case .empty, .marker:
                        self[p] = .forbidden
                    default:
                        break
                    }
                }
            }
            if treeCount > 3 || treeCount == 3 && info.blockIndexes.count > 1 { notSolved(info: info) }
            // 2. The board is divided into many areas. You have to place a triomino
            // into each area.
            if treeCount == 3 && info.blockIndexes.count == 1 {
                info.trees.sort()
                var treeOffsets = [Position]()
                let p2 = Position(info.trees.min { $0.row < $1.row }!.row, info.trees.min { $0.col < $1.col }!.col)
                for p in info.trees {
                    treeOffsets.append(p - p2)
                }
                info.triominoIndex = MiniLitsGame.triominos.firstIndex { $0 == treeOffsets }
                if info.triominoIndex == nil { notSolved(info: info) }
            }
            if treeCount < 3 { isSolved = false }
        }
        // 3. No two adjacent (touching horizontally / vertically) triominos should
        // be of equal shape & orientation.
        for i in 0..<infos.count {
            let info = infos[i]
            guard let index = info.triominoIndex else {continue}
            if info.neighborIndexes.contains(where: { infos[$0].triominoIndex == index }) { notSolved(info: info) }
        }
        guard isSolved else {return}
        // 4. All the shaded cells should form a valid Nurikabe.
        let block = blocks[0]
        rule2x2: for p in block {
            for os in MiniLitsGame.offset3 {
                guard block.contains(p + os) else { continue rule2x2 }
            }
            isSolved = false
            for os in MiniLitsGame.offset3 {
                self[p + os] = .tree(state: .error)
            }
        }
    }
}
