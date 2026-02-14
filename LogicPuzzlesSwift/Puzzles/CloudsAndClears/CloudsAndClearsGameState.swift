//
//  CloudsAndClearsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CloudsAndClearsGameState: GridGameState<CloudsAndClearsGameMove> {
    var game: CloudsAndClearsGame {
        get { getGame() as! CloudsAndClearsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CloudsAndClearsDocument.sharedInstance }
    var objArray = [CloudsAndClearsObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> CloudsAndClearsGameState {
        let v = CloudsAndClearsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CloudsAndClearsGameState) -> CloudsAndClearsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CloudsAndClearsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CloudsAndClearsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> CloudsAndClearsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CloudsAndClearsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CloudsAndClearsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout CloudsAndClearsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .cloud
        case .cloud: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .cloud : .empty
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 3/Clouds and Clears

        Summary
        Holes in the sky

        Description
        1. Paint the clouds according to the numbers.
        2. Each cloud or empty Sky move contains a single number that is the extension of the region
           itself.
        3. On a region there can be other numbers. These will indicate how many empty (non-cloud) tiles
           around it (diagonal too) including itself.
    */
    private func updateIsSolved() {
        isSolved = true
        var clouds = [[Position]]()
        var empties = [[Position]]()
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let node = g.addNode(p.description)
                pos2node[p] = node
            }
        }
        for (p, node) in pos2node {
            for i in 0..<4  {
                let p2 = p + CloudsAndClearsGame.offset[i]
                guard let node2 = pos2node[p2], self[p2].isCloud == self[p].isCloud else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map({ $0.0 }).sorted()
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            if self[area[0]].isCloud {
                clouds.append(area)
            } else {
                empties.append(area)
            }
        }
        // 2. Each cloud or empty Sky move contains a single number that is the extension of the region
        //    itself.
        // 3. On a region there can be other numbers. These will indicate how many empty (non-cloud) tiles
        //    around it (diagonal too) including itself.
        for (p, n2) in game.pos2hint {
            let area = clouds.first { $0.contains(p) } ?? empties.first { $0.contains(p) }!
            let n3 = area.count
            let n1 = CloudsAndClearsGame.offset2.count {
                let p2 = p + $0
                return isValid(p: p2) && !self[p2].isCloud
            }
            let s: HintState = n1 == n2 || n3 == n2 ? .complete : n1 > n2 ? .normal : .error
            pos2state[p] = s
            if s != .complete {isSolved = false}
        }
    }
}
