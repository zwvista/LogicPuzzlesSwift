//
//  AssemblyInstructionsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import OrderedCollections

class AssemblyInstructionsGameState: GridGameState<AssemblyInstructionsGameMove> {
    var game: AssemblyInstructionsGame {
        get { getGame() as! AssemblyInstructionsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { AssemblyInstructionsDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> AssemblyInstructionsGameState {
        let v = AssemblyInstructionsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: AssemblyInstructionsGameState) -> AssemblyInstructionsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: AssemblyInstructionsGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout AssemblyInstructionsGameMove) -> GameOperationType {
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
        let p = move.p, p2 = p + AssemblyInstructionsGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return .invalid }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout AssemblyInstructionsGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        let o = self[move.p][move.dir]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .line
        case .line: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .line : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 4/Assembly Instructions

        Summary
        New screw legs 'A' to seat 'C' using bolts 'J'...

        Description
        1. Divide the board so that every letter corresponds to a 'part' which
           has the same shape and orientation everywhere it is found.
        2. So for example if letter 'A' is a 2x3 rectangle, every 'A' on the board
           will correspond to a 2x3 rectangle and 'A' will appear in the same position
           in the rectangle itself.
        3. If letter 'B' has an L shape with the letter on the top left, every 'B'
           will have an L shape with the letter on the top left, etc.
    */
    private func updateIsSolved() {
        isSolved = true
        var ch2areas = [Character: [[Position]]]()
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
                    guard self[p + AssemblyInstructionsGame.offset2[i]][AssemblyInstructionsGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + AssemblyInstructionsGame.offset[i]]!)
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { p in game.pos2hint[p] != nil }
            // 1. Divide the board so that every letter corresponds to a 'part'
            if rng.count != 1 {
                for p in rng {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let ch = game.pos2hint[rng[0]]!
            ch2areas[ch, default: []].append(area)
        }
        for (ch, areas) in ch2areas {
            if areas.count != game.ch2rng[ch]!.count {
                isSolved = false
                for area in areas {
                    let pHint = area.first { game.pos2hint[$0] != nil }!
                    pos2state[pHint] = .normal
                }
                continue
            }
            // 1. every letter corresponds to a 'part' which
            // has the same shape and orientation everywhere it is found.
            let cnt = Set(areas.map { area in
                var r1 = rows, c1 = cols
                for p in area {
                    if r1 > p.row { r1 = p.row }
                    if c1 > p.col { c1 = p.col }
                }
                let p1 = Position(r1, c1)
                let pHint = area.first { game.pos2hint[$0] != nil }!
                return AssemblyInstructionsPart(part: area.map { $0 - p1 }.sorted(), hint: pHint - p1)
            }).count
            let s: HintState = cnt == 1 ? .complete : .error
            if s != .complete { isSolved = false }
            for area in areas {
                let pHint = area.first { game.pos2hint[$0] != nil }!
                pos2state[pHint] = s
            }
        }
    }
}
