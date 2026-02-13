//
//  OrchardsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class OrchardsGameState: GridGameState<OrchardsGameMove> {
    var game: OrchardsGame {
        get { getGame() as! OrchardsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { OrchardsDocument.sharedInstance }
    var objArray = [OrchardsObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> OrchardsGameState {
        let v = OrchardsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: OrchardsGameState) -> OrchardsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: OrchardsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<OrchardsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> OrchardsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> OrchardsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout OrchardsGameMove) -> GameOperationType {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout OrchardsGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: markerOption)
        func f(o: OrchardsObject) -> OrchardsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tree()
            case .tree:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tree() : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 11/Orchards

        Summary
        Plant the trees. Very close, this time!

        Description
        1. In a reverse of 'Parks', you're now planting Trees close together in
           neighboring country areas.
        2. These are Apple Trees, which must cross-pollinate, thus must be planted
           in pairs - horizontally or vertically touching.
        3. A Tree must be touching just one other Tree: you can't put three or
           more contiguous Trees.
        4. At the same time, like in Parks, every country area must have exactly
           two Trees in it.
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
                    self[p] = .tree()
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            for os in OrchardsGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(node, neighbor: node2)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let trees = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            // 2. These are Apple Trees, which must cross-pollinate, thus must be planted
            // in pairs - horizontally or vertically touching.
            if trees.count != 2 { isSolved = false }
            // 3. A Tree must be touching just one other Tree: you can't put three or
            // more contiguous Trees.
            if trees.count > 2 {
                for p in trees {
                    self[p] = .tree(state: .error)
                }
            }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
        }
        for a in game.areas {
            var trees = [Position]()
            let n2 = 2
            for p in a {
                if case .tree = self[p] { trees.append(p) }
            }
            let n1 = trees.count
            // 4. At the same time, like in Parks, every country area must have exactly
            // two Trees in it.
            if n1 != n2 { isSolved = false }
            for p in a {
                switch self[p] {
                case let .tree(state):
                    self[p] = .tree(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .empty, .marker:
                    if n1 == n2 && allowedObjectsOnly { self[p] = .forbidden }
                default:
                    break
                }
            }
        }
    }
}
