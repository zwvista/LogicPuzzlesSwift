//
//  AbcGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class AbcGameState: CellsGameState {
    var game: AbcGame {return gameBase as! AbcGame}
    var objArray = [AbcObject]()
    var row2hint = [String]()
    var col2hint = [String]()
    var options: AbcGameProgress { return AbcDocument.sharedInstance.gameProgress }
    
    override func copy() -> AbcGameState {
        let v = AbcGameState(game: gameBase)
        return setup(v: v)
    }
    func setup(v: AbcGameState) -> AbcGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2hint = row2hint
        v.col2hint = col2hint
        return v
    }
    
    required init(game: CellsGameBase) {
        super.init(game: game)
        objArray = Array<AbcObject>(repeating: AbcObject(), count: rows * cols)
        row2hint = Array<String>(repeating: "", count: rows)
        col2hint = Array<String>(repeating: "", count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> AbcObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> AbcObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout AbcGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout AbcGameMove) -> Bool {
        let markerOption = AbcMarkerOptions(rawValue: options.markerOption)
        func f(o: AbcObject) -> AbcObject {
            switch o {
            case .normal:
                return markerOption == .markerBeforeDarken ? .marker : .darken
            case .darken:
                return markerOption == .markerAfterDarken ? .marker : .normal
            case .marker:
                return markerOption == .markerBeforeDarken ? .darken : .normal
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        var chars = ""
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
                    pos2node[p] = g.addNode(label: p.description)
                }
            }
        }
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
                g.addEdge(source: node, neighbor: node2)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
        if pos2node.count != nodesExplored.count {isSolved = false}
    }
}
