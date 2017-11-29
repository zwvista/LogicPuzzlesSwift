//
//  ProductSentinelsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ProductSentinelsGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: ProductSentinelsGame {
        get {return getGame() as! ProductSentinelsGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: ProductSentinelsDocument { return ProductSentinelsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return ProductSentinelsDocument.sharedInstance }
    var objArray = [ProductSentinelsObject]()
    
    override func copy() -> ProductSentinelsGameState {
        let v = ProductSentinelsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ProductSentinelsGameState) -> ProductSentinelsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ProductSentinelsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ProductSentinelsObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> ProductSentinelsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> ProductSentinelsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout ProductSentinelsGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 {return false}
        guard String(describing: o1) != String(describing: o2) else {return false}
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout ProductSentinelsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: ProductSentinelsObject) -> ProductSentinelsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tower(state: .normal)
            case .tower:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tower(state: .normal) : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 11/Product Sentinels

        Summary
        Multiplicative Towers

        Description
        1. On the Board there are a few sentinels. These sentinels are marked with
           a number.
        2. The number tells you the product of the tiles that Sentinel can control
           (see) from there vertically and horizontally. This includes the tile 
           where he is located.
        3. You must put Towers on the Boards in accordance with these hints, keeping
           in mind that a Tower blocks the Sentinel View.
        4. The restrictions are that there must be a single continuous Garden, and
           two Towers can't touch horizontally or vertically.
        5. Towers can't go over numbered squares. But numbered squares don't block
           Sentinel View.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .tower:
                    self[p] = .tower(state: .normal)
                case .forbidden:
                    self[p] = .empty
                    fallthrough
                default:
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        for p in pos2node.keys {
            for os in SentinelsGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(pos2node[p]!, neighbor: node2)
                }
            }
        }
        // 4. two Towers can't touch horizontally or vertically.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor() -> Bool {
                    for os in ProductSentinelsGame.offset {
                        let p2 = p + os
                        if isValid(p: p2), case .tower = self[p2] {return true}
                    }
                    return false
                }
                switch self[p] {
                case let .tower(state):
                    self[p] = .tower(state: state == .normal && !hasNeighbor() ? .normal : .error)
                case .empty, .marker:
                    guard allowedObjectsOnly && hasNeighbor() else {continue}
                    self[p] = .forbidden
                default:
                    break
                }
            }
        }
        // 2. The number tells you the product of the tiles that Sentinel can control
        // (see) from there vertically and horizontally. This includes the tile
        // where he is located.
        for (p, n2) in game.pos2hint {
            var nums = [0, 0, 0, 0]
            var rng = [Position]()
            next: for i in 0..<4 {
                let os = ProductSentinelsGame.offset[i]
                var p2 = p + os
                while game.isValid(p: p2) {
                    switch self[p2] {
                    case .tower:
                        continue next
                    case .empty:
                        rng.append(p2)
                    default:
                        break
                    }
                    nums[i] += 1
                    p2 += os
                }
            }
            let n1 = (nums[0] + nums[2] + 1) * (nums[1] + nums[3] + 1)
            let s: HintState = n1 > n2 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {
                isSolved = false
            } else {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
        guard isSolved else {return}
        // 4. There must be a single continuous Garden
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count {isSolved = false}
    }
}
