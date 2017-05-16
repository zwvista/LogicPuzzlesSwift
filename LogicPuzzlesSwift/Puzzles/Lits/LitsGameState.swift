//
//  LitsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LitsAreaInfo {
    var trees = [Position]()
    var blockIndexes = Set<Int>()
    var neighborIndexes = Set<Int>()
    var tetrominoIndex: Int?
}

class LitsGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: LitsGame {
        get {return getGame() as! LitsGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: LitsDocument { return LitsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return LitsDocument.sharedInstance }
    var objArray = [LitsObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> LitsGameState {
        let v = LitsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LitsGameState) -> LitsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: LitsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LitsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> LitsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> LitsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout LitsGameMove) -> Bool {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout LitsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: LitsObject) -> LitsObject {
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
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 12/Lits

        Summary
        Tetris without the fat guy

        Description
        1. You play the game with all the Tetris pieces, except the square one.
        2. So in other words you use pieces of four squares (tetrominoes) in the
           shape of L, I, T and S, which can also be rotated or reflected (mirrored).
        3. The board is divided into many areas. You have to place a tetromino
           into each area respecting these rules:
        4. No two adjacent (touching horizontally / vertically) tetromino should
           be of equal shape, even counting rotations or reflections.
        5. All the shaded cells should form a valid Nurikabe (hence no fat guy).
    */
    private func updateIsSolved() {
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
            for os in LitsGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(pos2node[p]!, neighbor: node2)
                }
            }
        }
        var blocks = [[Position]]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let block = pos2node.filter({(p, _) in nodesExplored.contains(p.description)}).map{$0.0}
            blocks.append(block)
            pos2node = pos2node.filter({(p, _) in !nodesExplored.contains(p.description)})
        }
        if blocks.count != 1 {isSolved = false}
        var infos = [LitsAreaInfo]()
        for i in 0..<game.areas.count {
            infos.append(LitsAreaInfo())
        }
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
                for os in LitsGame.offset {
                    let p2 = p + os
                    guard let index = infos.index(where: {$0.trees.contains(p2)}),
                        index != i else {continue}
                    info.neighborIndexes.insert(index)
                }
            }
        }
        func notSolved(info: LitsAreaInfo) {
            isSolved = false
            for p in info.trees {
                self[p] = .tree(state: .error)
            }
        }
        for i in 0..<infos.count {
            let info = infos[i]
            let treeCount = info.trees.count
            if treeCount >= 4 && allowedObjectsOnly {
                for p in game.areas[i] {
                    switch self[p] {
                    case .empty, .marker:
                        self[p] = .forbidden
                    default:
                        break
                    }
                }
            }
            if treeCount > 4 || treeCount == 4 && info.blockIndexes.count > 1 {notSolved(info: info)}
            if treeCount == 4 && info.blockIndexes.count == 1 {
                info.trees.sort()
                var treeOffsets = [Position]()
                let p2 = Position(info.trees.min(by: {$0.row < $1.row})!.row, info.trees.min(by: {$0.col < $1.col})!.col)
                for p in info.trees {
                    treeOffsets.append(p - p2)
                }
                info.tetrominoIndex = LitsGame.tetrominoes.index(where: {$0.contains(where: {$0 == treeOffsets})})
                if info.tetrominoIndex == nil {notSolved(info: info)}
            }
            if treeCount < 4 {isSolved = false}
        }
        for i in 0..<infos.count {
            let info = infos[i]
            guard let index = info.tetrominoIndex else {continue}
            if info.neighborIndexes.contains(where: {infos[$0].tetrominoIndex == index}) {notSolved(info: info)}
        }
        guard isSolved else {return}
        let block = blocks[0]
        rule2x2:
        for p in block {
            for os in LitsGame.offset3 {
                guard block.contains(p + os) else {continue rule2x2}
            }
            isSolved = false
            for os in LitsGame.offset3 {
                self[p + os] = .tree(state: .error)
            }
        }
    }
}
