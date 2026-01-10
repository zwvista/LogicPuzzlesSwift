//
//  PipemaniaGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PipemaniaGameState: GridGameState<PipemaniaGameMove> {
    var game: PipemaniaGame {
        get { getGame() as! PipemaniaGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PipemaniaDocument.sharedInstance }
    var objArray = [PipemaniaObject]()
    
    override func copy() -> PipemaniaGameState {
        let v = PipemaniaGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PipemaniaGameState) -> PipemaniaGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PipemaniaGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> PipemaniaObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PipemaniaObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout PipemaniaGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), case .empty = game[p], String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout PipemaniaGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: PipemaniaObject) -> PipemaniaObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .flower(state: .normal)
            case .flower:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .flower(state: .normal) : .empty
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
        iOS Game: 100 Logic Games 2/Puzzle Set 5/Pipemania

        Summary
        Back to the 80s

        Description
        1. The former contractor for your present client left the work unfinished.
           In order not to waste what has bee done, you should complete the pipe
           loop, using the pieces available.
        2. Complete the board using all the tiles and form a single closed loop.
        3. The loop can cross itself.
        4. please note “a single closed loop" means that assuming the flow is straight
           even when the pipe crosses itself, i.e. following the pipe in straight lines
           (not turning at crossings).
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
                case .flower:
                    self[p] = .flower(state: .normal)
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
            }
        }
        for (p, node) in pos2node {
            for os in PipemaniaGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 2. More exactly, you have to join the existing flowers by adding more of
        // them, creating a single path of flowers touching horizontally or
        // vertically.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        
        var flowers = [Position]()
        // 3. At the same time, you can't line up horizontally or vertically more
        // than 3 flowers (thus Forbidden Four).
        func invalidFlowers() -> Bool {
            flowers.count > 3
        }
        func checkFlowers() {
            if invalidFlowers() {
                isSolved = false
                for p in flowers {
                    self[p] = .flower(state: .error)
                }
            }
            flowers.removeAll()
        }
        func checkForbidden(p: Position, indexes: [Int]) {
            guard allowedObjectsOnly else {return}
            for i in indexes {
                let os = PipemaniaGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) {
                    guard case .flower = self[p2] else {break}
                    flowers.append(p2)
                    p2 += os
                }
            }
            if invalidFlowers() { self[p] = .forbidden }
            flowers.removeAll()
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .flower:
                    flowers.append(p)
                case .empty, .marker:
                    checkFlowers()
                    checkForbidden(p: p, indexes: [1,3])
                default:
                    checkFlowers()
                }
            }
            checkFlowers()
        }
        for c in 0..<cols {
            for r in 0..<rows {
                let p = Position(r, c)
                switch self[p] {
                case .flower:
                    flowers.append(p)
                case .empty, .marker:
                    checkFlowers()
                    checkForbidden(p: p, indexes: [0,2])
                default:
                    checkFlowers()
                }
            }
            checkFlowers()
        }
    }
}
