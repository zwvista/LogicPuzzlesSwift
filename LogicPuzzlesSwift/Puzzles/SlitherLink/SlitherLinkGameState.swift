//
//  SlitherLinkGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SlitherLinkGameState: CellsGameState {
    var game: SlitherLinkGame {return gameBase as! SlitherLinkGame}
    var objArray = [SlitherLinkDotObject]()
    var pos2state = [Position: HintState]()
    var options: SlitherLinkGameProgress { return SlitherLinkDocument.sharedInstance.gameProgress }
    
    override func copy() -> SlitherLinkGameState {
        let v = SlitherLinkGameState(game: gameBase)
        return setup(v: v)
    }
    func setup(v: SlitherLinkGameState) -> SlitherLinkGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: CellsGameBase) {
        super.init(game: game)
        objArray = Array<SlitherLinkDotObject>(repeating: Array<SlitherLinkObject>(repeating: .empty, count: 4), count: rows * cols)
    }
    
    subscript(p: Position) -> SlitherLinkDotObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> SlitherLinkDotObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout SlitherLinkGameMove) -> Bool {
        var changed = false
        func f(o1: inout SlitherLinkObject, o2: inout SlitherLinkObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let p = move.p
        switch move.objOrientation {
        case .horizontal:
            f(o1: &self[p][1], o2: &self[p + SlitherLinkGame.offset[1]][3])
            if changed {updateIsSolved()}
        case .vertical:
            f(o1: &self[p][2], o2: &self[p + SlitherLinkGame.offset[2]][0])
            if changed {updateIsSolved()}
        }
        return changed
    }
    
    func switchObject(move: inout SlitherLinkGameMove) -> Bool {
        let markerOption = SlitherLinkMarkerOptions(rawValue: options.markerOption)
        func f(o: SlitherLinkObject) -> SlitherLinkObject {
            switch o {
            case .empty:
                return markerOption == .markerBeforeLine ? .marker : .line
            case .line:
                return markerOption == .markerAfterLine ? .marker : .empty
            case .marker:
                return markerOption == .markerBeforeLine ? .line : .empty
            }
        }
        let p = move.p
        let o = f(o: self[p][move.objOrientation == .horizontal ? 1 : 2])
        move.obj = o
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2hint {
            var n1 = 0
            if self[p][1] == .line {n1 += 1}
            if self[p][2] == .line {n1 += 1}
            if self[p + Position(1, 1)][0] == .line {n1 += 1}
            if self[p + Position(1, 1)][3] == .line {n1 += 1}
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0 ..< rows {
            for c in 0 ..< cols {
                let p = Position(r, c)
                let n = self[p].filter({$0 == .line}).count
                switch n {
                case 0:
                    continue
                case 2:
                    pos2node[p] = g.addNode(label: p.description)
                default:
                    isSolved = false
                    return
                }
            }
        }
        for p in pos2node.keys {
            let dotObj = self[p]
            for i in 0 ..< 4 {
                guard dotObj[i] == .line else {continue}
                let p2 = p + SlitherLinkGame.offset[i]
                g.addEdge(source: pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
        let n1 = nodesExplored.count
        let n2 = pos2node.values.count
        if n1 != n2 {isSolved = false}
    }
}
