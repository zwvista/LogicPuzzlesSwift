//
//  OrchardsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class OrchardsGameState: GridGameState, OrchardsMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: OrchardsGame {
        get {return getGame() as! OrchardsGame}
        set {setGame(game: newValue)}
    }
    var objArray = [OrchardsObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> OrchardsGameState {
        let v = OrchardsGameState(game: game)
        return setup(v: v)
    }
    func setup(v: OrchardsGameState) -> OrchardsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: OrchardsGame) {
        super.init(game: game)
        objArray = Array<OrchardsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> OrchardsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> OrchardsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout OrchardsGameMove) -> Bool {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout OrchardsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: OrchardsObject) -> OrchardsObject {
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
            for os in OrchardsGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(pos2node[p]!, neighbor: node2)
                }
            }
        }
        while !pos2node.isEmpty {
            let node = pos2node.first!.value
            let nodesExplored = breadthFirstSearch(g, source: node)
            let trees = pos2node.filter({(p, _) in nodesExplored.contains(p.description)}).map{$0.0}
            if trees.count != 2 {isSolved = false}
            if trees.count > 2 {
                for p in trees {
                    self[p] = .tree(state: .error)
                }
            }
            pos2node = pos2node.filter({(p, _) in !nodesExplored.contains(p.description)})
        }
        for a in game.areas {
            var trees = [Position]()
            let n2 = 2
            for p in a {
                if case .tree = self[p] {trees.append(p)}
            }
            let n1 = trees.count
            if n1 != n2 {isSolved = false}
            for p in a {
                switch self[p] {
                case let .tree(state):
                    self[p] = .tree(state: state == .normal && n1 <= n2 ? .normal : .error)
                case .empty, .marker:
                    if n1 == n2 && allowedObjectsOnly {self[p] = .forbidden}
                default:
                    break
                }
            }
        }
    }
}
