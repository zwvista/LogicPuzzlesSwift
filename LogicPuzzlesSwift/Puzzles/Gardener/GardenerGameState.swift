//
//  GardenerGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GardenerGameState: GridGameState<GardenerGame, GardenerDocument, GardenerGameMove> {
    override var gameDocument: GardenerDocument { GardenerDocument.sharedInstance }
    var objArray = [GardenerObject]()
    var pos2state = [Position: HintState]()
    var invalidSpacesHorz = Set<Position>()
    var invalidSpacesVert = Set<Position>()

    override func copy() -> GardenerGameState {
        let v = GardenerGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: GardenerGameState) -> GardenerGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: GardenerGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<GardenerObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> GardenerObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GardenerObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout GardenerGameMove) -> Bool {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout GardenerGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GardenerObject) -> GardenerObject {
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
        guard isValid(p: p) else { return false }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 7/Gardener

        Summary
        Hitori Flower Planting

        Description
        1. The Board represents a Garden, divided in many rectangular Flowerbeds.
        2. The owner of the Garden wants you to plant Flowers according to these
           rules.
        3. A number tells you how many Flowers you must plant in that Flowerbed.
           A Flowerbed without number can have any quantity of Flowers.
        4. Flowers can't be horizontally or vertically touching.
        5. All the remaining Garden space where there are no Flowers must be
           interconnected (horizontally or vertically), as he wants to be able
           to reach every part of the Garden without treading over Flowers.
        6. Lastly, there must be enough balance in the Garden, so a straight
           line (horizontally or vertically) of non-planted tiles can't span
           for more than two Flowerbeds.
        7. In other words, a straight path of empty space can't pass through
           three or more Flowerbeds.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .forbidden = self[r, c] { self[r, c] = .empty }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor() -> Bool {
                    for os in GardenerGame.offset {
                        let p2 = p + os
                        if isValid(p: p2), case .tree = self[p2] { return true }
                    }
                    return false
                }
                func f() { pos2node[p] = g.addNode(p.description) }
                switch self[p] {
                case .tree:
                    // 4. Flowers can't be horizontally or vertically touching.
                    let s: AllowedObjectState = !hasNeighbor() ? .normal : .error
                    self[p] = .tree(state: s)
                    if s == .error { isSolved = false }
                case .empty, .marker:
                    // 4. Flowers can't be horizontally or vertically touching.
                    if allowedObjectsOnly && hasNeighbor() { self[p] = .forbidden }
                    f()
                default:
                    f()
                }
            }
        }
        for (p, node) in pos2node {
            for os in FourMeNotGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 5. All the remaining Garden space where there are no Flowers must be
        // interconnected (horizontally or vertically), as he wants to be able
        // to reach every part of the Garden without treading over Flowers.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        
        // 3. A number tells you how many Flowers you must plant in that Flowerbed.
        // A Flowerbed without number can have any quantity of Flowers.
        for (p, (n2, i)) in game.pos2hint {
            let area = game.areas[i]
            var n1 = 0
            for p2 in area {
                if case .tree = self[p2] { n1 += 1 }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
            if s != .normal && allowedObjectsOnly {
                for p2 in area {
                    switch self[p2] {
                    case .empty, .marker:
                        self[p2] = .forbidden
                    default:
                        break
                    }
                }
            }
        }
        var spaces = [Position]()
        // 6. Lastly, there must be enough balance in the Garden, so a straight
        // line (horizontally or vertically) of non-planted tiles can't span
        // for more than two Flowerbeds.
        // 7. In other words, a straight path of empty space can't pass through
        // three or more Flowerbeds.
        func checkSpaces(isHorz: Bool) {
            if Set<Int>(spaces.map { game.pos2area[$0]! }).count > 2 {
                isSolved = false
                if isHorz {
                    invalidSpacesHorz = invalidSpacesHorz.union(spaces)
                } else {
                    invalidSpacesVert = invalidSpacesVert.union(spaces)
                }
            }
            spaces.removeAll()
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if case .tree = self[p] {
                    checkSpaces(isHorz: true)
                } else {
                    spaces.append(p)
                }
            }
            checkSpaces(isHorz: true)
        }
        for c in 0..<cols {
            for r in 0..<rows {
                let p = Position(r, c)
                if case .tree = self[p] {
                    checkSpaces(isHorz: false)
                } else {
                    spaces.append(p)
                }
            }
            checkSpaces(isHorz: false)
        }
    }
}
