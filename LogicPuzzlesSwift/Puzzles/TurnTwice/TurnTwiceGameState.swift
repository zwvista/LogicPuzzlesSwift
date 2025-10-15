//
//  TurnTwiceGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TurnTwiceGameState: GridGameState<TurnTwiceGameMove> {
    var game: TurnTwiceGame {
        get { getGame() as! TurnTwiceGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TurnTwiceDocument.sharedInstance }
    var objArray = [TurnTwiceObject]()
    
    override func copy() -> TurnTwiceGameState {
        let v = TurnTwiceGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TurnTwiceGameState) -> TurnTwiceGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TurnTwiceGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> TurnTwiceObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TurnTwiceObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TurnTwiceGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), case .empty = game[p], String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TurnTwiceGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: TurnTwiceObject) -> TurnTwiceObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .signpost(state: .normal)
            case .signpost:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .signpost(state: .normal) : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p), case .empty = game[p] else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 9/Four-Me-Not

        Summary
        It seems we do a lot of gardening in this game!

        Description
        1. In Four-Me-Not (or Forbidden Four) you need to create a continuous
           signpost bed without putting four signposts in a row.
        2. More exactly, you have to join the existing signposts by adding more of
           them, creating a single path of signposts touching horizontally or
           vertically.
        3. At the same time, you can't line up horizontally or vertically more
           than 3 signposts (thus Forbidden Four).
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
                case .signpost:
                    self[p] = .signpost(state: .normal)
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            for os in TurnTwiceGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 2. More exactly, you have to join the existing signposts by adding more of
        // them, creating a single path of signposts touching horizontally or
        // vertically.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        
        var signposts = [Position]()
        // 3. At the same time, you can't line up horizontally or vertically more
        // than 3 signposts (thus Forbidden Four).
        func invalidsignposts() -> Bool {
            signposts.count > 3
        }
        func checksignposts() {
            if invalidsignposts() {
                isSolved = false
                for p in signposts {
                    self[p] = .signpost(state: .error)
                }
            }
            signposts.removeAll()
        }
        func checkForbidden(p: Position, indexes: [Int]) {
            guard allowedObjectsOnly else {return}
            for i in indexes {
                let os = TurnTwiceGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) {
                    guard case .signpost = self[p2] else {break}
                    signposts.append(p2)
                    p2 += os
                }
            }
            if invalidsignposts() { self[p] = .forbidden }
            signposts.removeAll()
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .signpost:
                    signposts.append(p)
                case .empty, .marker:
                    checksignposts()
                    checkForbidden(p: p, indexes: [1,3])
                default:
                    checksignposts()
                }
            }
            checksignposts()
        }
        for c in 0..<cols {
            for r in 0..<rows {
                let p = Position(r, c)
                switch self[p] {
                case .signpost:
                    signposts.append(p)
                case .empty, .marker:
                    checksignposts()
                    checkForbidden(p: p, indexes: [0,2])
                default:
                    checksignposts()
                }
            }
            checksignposts()
        }
    }
}
