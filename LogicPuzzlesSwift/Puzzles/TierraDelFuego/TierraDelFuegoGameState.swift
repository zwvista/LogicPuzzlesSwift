//
//  TierraDelFuegoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TierraDelFuegoGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: TierraDelFuegoGame {
        get {return getGame() as! TierraDelFuegoGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: TierraDelFuegoDocument { return TierraDelFuegoDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return TierraDelFuegoDocument.sharedInstance }
    var objArray = [TierraDelFuegoObject]()
    
    override func copy() -> TierraDelFuegoGameState {
        let v = TierraDelFuegoGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TierraDelFuegoGameState) -> TierraDelFuegoGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TierraDelFuegoGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TierraDelFuegoObject>(repeating: .empty, count: rows * cols)
        for (p, ch) in game.pos2hint {
            self[p] = .hint(id: ch, state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> TierraDelFuegoObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> TierraDelFuegoObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout TierraDelFuegoGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil, String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout TierraDelFuegoGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: TierraDelFuegoObject) -> TierraDelFuegoObject {
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
        guard isValid(p: p), game.pos2hint[p] == nil else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 11/Tierra Del Fuego

        Summary
        Fuegians!

        Description
        1. The board represents the 'Tierra del Fuego' archipelago, where native
           tribes, the Fuegians, live.
        2. Being organized in tribes, each tribe, marked with a different letter,
           has occupied an island in the archipelago.
        3. The archipelago is peculiar because all bodies of water separating the
           islands are identical in shape and occupied a 2*1 or 1*2 space.
        4. These bodies of water can only touch diagonally.
        5. Your task is to find these bodies of water.
        6. Please note there are no hidden tribes or islands without a tribe on it.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .tree:
                    self[p] = .tree(state: .normal)
                case let .hint(id, _):
                    self[p] = .hint(id: id, state: .normal)
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            var b1 = false
            if case .tree = self[p] {b1 = true}
            for os in TierraDelFuegoGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                var b2 = false
                if case .tree = self[p2] {b2 = true}
                if b1 == b2 {
                    g.addEdge(node, neighbor: node2)
                }
            }
        }
        while !pos2node.isEmpty {
            let kv = pos2node.first!
            let nodesExplored = breadthFirstSearch(g, source: kv.value)
            let area = pos2node.filter{nodesExplored.contains($0.0.description)}.map{$0.0}
            pos2node = pos2node.filter{!nodesExplored.contains($0.0.description)}
            if case .tree = self[kv.key] {
                // 3. The archipelago is peculiar because all bodies of water separating the
                // islands are identical in shape and occupied a 2*1 or 1*2 space.
                // 4. These bodies of water can only touch diagonally.
                if area.count != 2 {
                    isSolved = false
                } else if allowedObjectsOnly {
                    for p in area {
                        for os in TierraDelFuegoGame.offset {
                            let p2 = p + os
                            guard isValid(p: p2) else {continue}
                            switch self[p2] {
                            case .empty, .marker:
                                self[p2] = .forbidden
                            default:
                                break
                            }
                        }
                    }
                }
                if area.count > 2 {
                    for p in area {
                        if case .tree = self[p] {
                            self[p] = .tree(state: .error)
                        }
                    }
                }
            } else {
                // 2. Being organized in tribes, each tribe, marked with a different letter,
                // has occupied an island in the archipelago.
                var ids = Set<Character>()
                for p in area {
                    if case let .hint(id, _) = self[p] {
                        ids.insert(id)
                    }
                }
                if ids.count == 1 {
                    for p in area {
                        if case let .hint(id, _) = self[p] {
                            self[p] = .hint(id: id, state: .complete)
                        }
                    }
                } else {
                    isSolved = false
                }
            }
        }
    }
}
