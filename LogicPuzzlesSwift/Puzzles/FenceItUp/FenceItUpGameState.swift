//
//  FenceItUpGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FenceItUpGameState: GridGameState, FenceItUpMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: FenceItUpGame {
        get {return getGame() as! FenceItUpGame}
        set {setGame(game: newValue)}
    }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> FenceItUpGameState {
        let v = FenceItUpGameState(game: game)
        return setup(v: v)
    }
    func setup(v: FenceItUpGameState) -> FenceItUpGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: FenceItUpGame) {
        super.init(game: game);
        objArray = game.objArray
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
    }
    
    subscript(p: Position) -> GridDotObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout FenceItUpGameMove) -> Bool {
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
        let p = move.p, p2 = p + FenceItUpGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] != .line else {return false}
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed {updateIsSolved()}
        return changed
    }
    
    func switchObject(move: inout FenceItUpGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                pos2node[p] = g.addNode(label: p.description)
            }
        }
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for i in 0..<4 {
                    if self[p + FenceItUpGame.offset2[i]][FenceItUpGame.dirs[i]] != .line {
                        g.addEdge(source: pos2node[p]!, neighbor: pos2node[p + FenceItUpGame.offset[i]]!)
                    }
                }
            }
        }
        while !pos2node.isEmpty {
            let node = pos2node.first!.value
            let nodesExplored = breadthFirstSearch(g, source: node)
            let area = pos2node.filter({(p, _) in nodesExplored.contains(p.description)}).map{$0.0}
            pos2node = pos2node.filter({(p, _) in !nodesExplored.contains(p.description)})
            let rng = area.filter({p in game.pos2hint[p] != nil})
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let p2 = rng[0]
            let n2 = game.pos2hint[p2]!
            var n1 = 0
            for p in area {
                for i in 0..<4 {
                    if self[p + FenceItUpGame.offset2[i]][FenceItUpGame.dirs[i]] == .line {n1 += 1}
                }
            }
            pos2state[p2] = n1 == n2 ? .complete : .error
            if pos2state[p2] != .complete {isSolved = false}
        }
    }
}
