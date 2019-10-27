//
//  NumberCrosswordsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NumberCrosswordsGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: NumberCrosswordsGame {
        get {return getGame() as! NumberCrosswordsGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: NumberCrosswordsDocument { return NumberCrosswordsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return NumberCrosswordsDocument.sharedInstance }
    var objArray = [NumberCrosswordsObject]()
    var row2hint = [String]()
    var col2hint = [String]()
    
    override func copy() -> NumberCrosswordsGameState {
        let v = NumberCrosswordsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NumberCrosswordsGameState) -> NumberCrosswordsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2hint = row2hint
        v.col2hint = col2hint
        return v
    }
    
    required init(game: NumberCrosswordsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<NumberCrosswordsObject>(repeating: NumberCrosswordsObject(), count: rows * cols)
        row2hint = Array<String>(repeating: "", count: rows)
        col2hint = Array<String>(repeating: "", count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> NumberCrosswordsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> NumberCrosswordsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout NumberCrosswordsGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout NumberCrosswordsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: NumberCrosswordsObject) -> NumberCrosswordsObject {
            switch o {
            case .normal:
                return markerOption == .markerFirst ? .marker : .darken
            case .darken:
                return markerOption == .markerLast ? .marker : .normal
            case .marker:
                return markerOption == .markerFirst ? .darken : .normal
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games 2/Puzzle Set 1/Number Crosswords

        Summary
        More crosswords for Robots

        Description
        1. Blacken some tiles, so that some of the numbers remain visible.
        2. Numbers outside the grid show the sums of the numbers in the
           remaining tiles in that row or column.
    */
    private func updateIsSolved() {
        isSolved = true
        var chars = ""
        // 1. The goal is to shade squares so that a number appears only once in a
        // row.
        for r in 0..<rows {
            chars = ""
            row2hint[r] = ""
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] != .darken else {continue}
                let ch = game[p]
                if chars.contains(String(ch)) {
                    isSolved = false
                    row2hint[r].append(ch)
                } else {
                    chars.append(ch)
                }
            }
        }
        // 1. The goal is to shade squares so that a number appears only once in a
        // column.
        for c in 0..<cols {
            chars = ""
            col2hint[c] = ""
            for r in 0..<rows {
                let p = Position(r, c)
                guard self[p] != .darken else {continue}
                let ch = game[p]
                if chars.contains(String(ch)) {
                    isSolved = false
                    col2hint[c].append(ch)
                } else {
                    chars.append(ch)
                }
            }
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngDarken = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .darken:
                    rngDarken.append(p)
                default:
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        // 2. While doing that, you must take care that shaded squares don't touch
        // horizontally or vertically between them.
        for p in rngDarken {
            for os in CloudsGame.offset {
                let p2 = p + os
                guard !rngDarken.contains(p2) else {isSolved = false; return}
            }
        }
        for (p, node) in pos2node {
            for os in CloudsGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 3. In the end all the un-shaded squares must form a single continuous area.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count {isSolved = false}
    }
}
