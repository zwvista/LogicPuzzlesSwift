//
//  LoopyGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LoopyGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: LoopyGame {
        get { getGame() as! LoopyGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: LoopyDocument { LoopyDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { LoopyDocument.sharedInstance }
    var objArray = [GridDotObject]()
    
    override func copy() -> LoopyGameState {
        let v = LoopyGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LoopyGameState) -> LoopyGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LoopyGame, isCopy: Bool = false) {
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
    
    private func isValidMove(move: inout LoopyGameMove) -> Bool {
        return !(move.p.row == rows - 1 && move.dir == 2 ||
            move.p.col == cols - 1 && move.dir == 1)
    }
    
    func setObject(move: inout LoopyGameMove) -> Bool {
        guard isValidMove(move: &move) else { return false }
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
        let p = move.p, p2 = p + LoopyGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] == .empty else { return false }
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed { updateIsSolved() }
        return changed
    }
    
    func switchObject(move: inout LoopyGameMove) -> Bool {
        guard isValidMove(move: &move) else { return false }
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
        iOS Game: Logic Games/Puzzle Set 5/Loopy

        Summary
        Loop a loop! And touch all the dots!

        Description
        1. Draw a single looping path. You have to touch all the dots. As usual,
           the path cannot have branches or cross itself.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].filter { $0 == .line }.count
                switch n {
                case 2:
                    pos2node[p] = g.addNode(p.description)
                default:
                    // 1. The path cannot have branches or cross itself.
                    // 1. You have to touch all the dots.
                    isSolved = false
                    return
                }
            }
        }
        for p in pos2node.keys {
            let dotObj = self[p]
            for i in 0..<4 {
                guard dotObj[i] == .line else {continue}
                let p2 = p + LoopyGame.offset[i]
                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        // 1. Draw a single looping path.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
