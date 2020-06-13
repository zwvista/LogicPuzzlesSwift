//
//  FourMeNotGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FourMeNotGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: FourMeNotGame {
        get {getGame() as! FourMeNotGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: FourMeNotDocument { FourMeNotDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { FourMeNotDocument.sharedInstance }
    var objArray = [FourMeNotObject]()
    
    override func copy() -> FourMeNotGameState {
        let v = FourMeNotGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FourMeNotGameState) -> FourMeNotGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FourMeNotGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> FourMeNotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FourMeNotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func setObject(move: inout FourMeNotGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p), case .empty = game[p], String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout FourMeNotGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: FourMeNotObject) -> FourMeNotObject {
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
        guard isValid(p: p), case .empty = game[p] else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 9/Four-Me-Not

        Summary
        It seems we do a lot of gardening in this game!

        Description
        1. In Four-Me-Not (or Forbidden Four) you need to create a continuous
           flower bed without putting four flowers in a row.
        2. More exactly, you have to join the existing flowers by adding more of
           them, creating a single path of flowers touching horizontally or
           vertically.
        3. At the same time, you can't line up horizontally or vertically more
           than 3 flowers (thus Forbidden Four).
        4. Some tiles are marked as squares and are just fixed blocks.
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
                case .forbidden:
                    self[p] = .empty
                case .tree:
                    self[p] = .tree(state: .normal)
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            for os in FourMeNotGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 2. More exactly, you have to join the existing flowers by adding more of
        // them, creating a single path of flowers touching horizontally or
        // vertically.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count {isSolved = false}
        
        var trees = [Position]()
        // 3. At the same time, you can't line up horizontally or vertically more
        // than 3 flowers (thus Forbidden Four).
        func invalidTrees() -> Bool {
            return trees.count > 3
        }
        func checkTrees() {
            if invalidTrees() {
                isSolved = false
                for p in trees {
                    self[p] = .tree(state: .error)
                }
            }
            trees.removeAll()
        }
        func checkForbidden(p: Position, indexes: [Int]) {
            guard allowedObjectsOnly else {return}
            for i in indexes {
                let os = FourMeNotGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) {
                    guard case .tree = self[p2] else {break}
                    trees.append(p2)
                    p2 += os
                }
            }
            if invalidTrees() {self[p] = .forbidden}
            trees.removeAll()
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .tree:
                    trees.append(p)
                case .empty, .marker:
                    checkTrees()
                    checkForbidden(p: p, indexes: [1,3])
                default:
                    checkTrees()
                }
            }
            checkTrees()
        }
        for c in 0..<cols {
            for r in 0..<rows {
                let p = Position(r, c)
                switch self[p] {
                case .tree:
                    trees.append(p)
                case .empty, .marker:
                    checkTrees()
                    checkForbidden(p: p, indexes: [0,2])
                default:
                    checkTrees()
                }
            }
            checkTrees()
        }
    }
}
