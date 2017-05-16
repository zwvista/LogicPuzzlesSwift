//
//  NeighboursGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NeighboursGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: NeighboursGame {
        get {return getGame() as! NeighboursGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: NeighboursDocument { return NeighboursDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return NeighboursDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> NeighboursGameState {
        let v = NeighboursGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NeighboursGameState) -> NeighboursGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: NeighboursGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
        updateIsSolved()
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
    
    func setObject(move: inout NeighboursGameMove) -> Bool {
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
        let p = move.p, p2 = p + NeighboursGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] != .line else {return false}
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed {updateIsSolved()}
        return changed
    }
    
    func switchObject(move: inout NeighboursGameMove) -> Bool {
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
    
    /*
        iOS Game: Logic Games/Puzzle Set 8/Neighbours

        Summary
        Neighbours, yes, but not equally sociable

        Description
        1. The board represents a piece of land bought by a bunch of people. They
           decided to split the land in equal parts.
        2. However some people are more social and some are less, so each owner
           wants an exact number of neighbours around him.
        3. Each number on the board represents an owner house and the number of
           neighbours he desires.
        4. Divide the land so that each one has an equal number of squares and
           the requested number of neighbours.
        5. Later on, there will be Question Marks, which represents an owner for
           which you don't know the neighbours preference.
    */
    private func updateIsSolved() {
        isSolved = true
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
                    guard self[p + NeighboursGame.offset2[i]][NeighboursGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + NeighboursGame.offset[i]]!)
                }
            }
        }
        var areas = [[Position]]()
        var pos2area = [Position: Int]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter({(p, _) in nodesExplored.contains(p.description)}).map{$0.0}
            areas.append(area)
            for p in area {
                pos2area[p] = areas.count
            }
            pos2node = pos2node.filter({(p, _) in !nodesExplored.contains(p.description)})
        }
        let n2 = game.areaSize
        for area in areas {
            let rng = area.filter({p in game.pos2hint[p] != nil})
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let p3 = rng[0]
            let n1 = area.count, n3 = game.pos2hint[p3]!
            func neighbours() -> Int {
                var indexes = Set<Int>()
                let idx = pos2area[area.first!]!
                for p in area {
                    for i in 0..<4 {
                        guard self[p + NeighboursGame.offset2[i]][NeighboursGame.dirs[i]] == .line else {continue}
                        let p2 = p + NeighboursGame.offset[i]
                        guard let idx2 = pos2area[p2] else {continue}
                        guard idx != idx2 else {return -1}
                        indexes.insert(idx2)
                    }
                }
                return indexes.count
            }
            pos2state[p3] = n1 == n2 && n3 == neighbours() ? .complete : .error
            if pos2state[p3] != .complete {isSolved = false}
        }
    }
}
