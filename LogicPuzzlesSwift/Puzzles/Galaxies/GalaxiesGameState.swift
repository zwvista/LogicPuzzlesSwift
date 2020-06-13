//
//  GalaxiesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import EZSwiftExtensions

class GalaxiesGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: GalaxiesGame {
        get {getGame() as! GalaxiesGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: GalaxiesDocument { GalaxiesDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { GalaxiesDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> GalaxiesGameState {
        let v = GalaxiesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: GalaxiesGameState) -> GalaxiesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: GalaxiesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        for p in game.galaxies {
            pos2state[p] = .normal
        }
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
    
    func setObject(move: inout GalaxiesGameMove) -> Bool {
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
        let p = move.p, p2 = p + GalaxiesGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else {return false}
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed {updateIsSolved()}
        return changed
    }
    
    func switchObject(move: inout GalaxiesGameMove) -> Bool {
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
        iOS Game: Logic Games/Puzzle Set 4/Galaxies

        Summary
        Fill the Symmetric Spiral Galaxies

        Description
        1. In the board there are marked centers of a few 'Spiral' Galaxies.
        2. These Galaxies are symmetrical to a rotation of 180 degrees. This
           means that rotating the shape of the Galaxy by 180 degrees (half a
           full turn) around the center, will result in an identical shape.
        3. In the end, all the space must be included in Galaxies and Galaxies
           can't overlap.
        4. There can be single tile Galaxies (with the center inside it) and
           some Galaxy center will be cross two or four tiles.
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
                    guard self[p + GalaxiesGame.offset2[i]][GalaxiesGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + GalaxiesGame.offset[i]]!)
                }
            }
        }
        var areas = [[Position]]()
        var pos2area = [Position: Int]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter{nodesExplored.contains($0.0.description)}.map{$0.0}
            areas.append(area)
            for p in area {
                pos2area[p] = areas.count
            }
            pos2node = pos2node.filter{!nodesExplored.contains($0.0.description)}
        }
        var n1 = 0
        for area in areas {
            let rng = game.galaxies.filter{p in area.contains(Position(p.row / 2, p.col / 2))}
            if rng.count != 1 {
                // 3. Galaxies can't overlap.
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false
            } else {
                // 2. These Galaxies are symmetrical to a rotation of 180 degrees. This
                // means that rotating the shape of the Galaxy by 180 degrees (half a
                // full turn) around the center, will result in an identical shape.
                let galaxy = rng.first!
                let b = area.testAll{p in area.contains(Position(galaxy.row - p.row - 1, galaxy.col - p.col - 1))}
                pos2state[galaxy] = b ? .complete : .error
                if !b {isSolved = false}
            }
            n1 += area.count
        }
        // 3. In the end, all the space must be included in Galaxies
        if n1 != rows * cols {isSolved = false}
    }
}
