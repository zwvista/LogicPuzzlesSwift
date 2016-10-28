//
//  HitoriGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct HitoriGameState {
    let game: HitoriGame
    var size: Position { return game.size }
    var rows: Int { return size.row }
    var cols: Int { return size.col }    
    func isValid(p: Position) -> Bool {
        return game.isValid(p: p)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return game.isValid(row: row, col: col)
    }
    var objArray = [HitoriObject]()
    var options: HitoriGameProgress { return HitoriDocument.sharedInstance.gameProgress }
    
    init(game: HitoriGame) {
        self.game = game
        objArray = Array<HitoriObject>(repeating: HitoriObject(), count: rows * cols)
    }
    
    subscript(p: Position) -> HitoriObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> HitoriObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    mutating func setObject(move: inout HitoriGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    mutating func switchObject(move: inout HitoriGameMove) -> Bool {
        let markerOption = HitoriMarkerOptions(rawValue: options.markerOption)
        func f(o: HitoriObject) -> HitoriObject {
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
    
    private(set) var isSolved = false
    
    private mutating func updateIsSolved() {
        isSolved = true
        var chars = Set<Character>()
        for r in 0 ..< rows {
            chars = []
            for c in 0 ..< cols {
                let p = Position(r, c)
                guard self[p] != .darken else {continue}
                let ch = game[p]
                guard !chars.contains(ch) else {isSolved = false; return}
                chars.insert(ch)
            }
        }
        for c in 0 ..< cols {
            chars = []
            for r in 0 ..< rows {
                let p = Position(r, c)
                guard self[p] != .darken else {continue}
                let ch = game[p]
                guard !chars.contains(ch) else {isSolved = false; return}
                chars.insert(ch)
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngDarken = [Position]()
        for r in 0 ..< rows {
            for c in 0 ..< cols {
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
