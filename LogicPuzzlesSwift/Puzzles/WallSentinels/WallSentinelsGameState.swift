//
//  WallSentinelsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class WallSentinelsGameState: GridGameState<WallSentinelsGameMove> {
    var game: WallSentinelsGame {
        get { getGame() as! WallSentinelsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { WallSentinelsDocument.sharedInstance }
    var objArray = [WallSentinelsObject]()
    
    override func copy() -> WallSentinelsGameState {
        let v = WallSentinelsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: WallSentinelsGameState) -> WallSentinelsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: WallSentinelsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> WallSentinelsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> WallSentinelsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout WallSentinelsGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        switch o1 {
        case .hintLand, .hintWall: return false
        default: break
        }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout WallSentinelsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: WallSentinelsObject) -> WallSentinelsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .wall
            case .wall:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .wall : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 11/Wall Sentinels

        Summary
        It's midnight and all is well!

        Description
        1. On the board there is a single continuous castle wall, which you
           must discover.
        2. The numbers on the board represent Sentinels (in a similar way to
           'Sentinels'). The Sentinels can be placed on the Wall or Land.
        3. The number tells you how many tiles that Sentinel can control (see)
           from there vertically and horizontally - of his type of tile.
        4. That means the number of a Land Sentinel indicates how many Land tiles
           are visible from there, up to Wall tiles or the grid border.
        5. That works the opposite way for Wall Sentinels: they control all the
           Wall tiles up to Land tiles or the grid border.
        6. The number includes the tile itself, where the Sentinel is located
           (again, like 'Sentinels').
        7. Lastly there is a single, orthogonally contiguous, Wall and it cannot
           contain 2*2 Wall tiles - just like Nurikabe.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func f(isWall: Bool, n2: Int) {
                    var n1 = 1
                    for os in WallSentinelsGame.offset {
                        var p2 = p + os
                        while isValid(p: p2) {
                            var isWall2 = false
                            switch self[p2] {
                            case .wall, .hintWall: isWall2 = true
                            default: break
                            }
                            if isWall2 != isWall {break}
                            n1 += 1
                            p2 += os
                        }
                    }
                    // 3. The number tells you how many tiles that Sentinel can control (see)
                    // from there vertically and horizontally - of his type of tile.
                    let s: HintState = (isWall ? n1 < n2 : n1 > n2) ? .normal : n1 == n2 ? .complete : .error
                    self[p] = isWall ? .hintWall(tiles: n2, state: s) : .hintLand(tiles: n2, state: s)
                    if s != .complete { isSolved = false }
                }
                switch self[p] {
                case let .hintLand(n2, _):
                    f(isWall: false, n2: n2)
                case let .hintWall(n2, _):
                    f(isWall: true, n2: n2)
                default:
                    break
                }
            }
        }
        if !isSolved {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .wall, .hintWall:
                    pos2node[p] = g.addNode(p.description)
                    // 7. The Wall cannot contain 2*2 Wall tiles.
                    if WallSentinelsGame.offset2.testAll({os in
                        let p2 = p + os
                        if !self.isValid(p: p2) { return false }
                        switch self[p2] {
                        case .wall, .hintWall: return true
                        default: return false
                        }
                    }) { isSolved = false; return }
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            for os in WallSentinelsGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 7. Lastly there is a single, orthogonally contiguous, Wall - just like Nurikabe.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
