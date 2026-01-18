//
//  DirectionalPlanksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DirectionalPlanksGameState: GridGameState<DirectionalPlanksGameMove> {
    var game: DirectionalPlanksGame {
        get { getGame() as! DirectionalPlanksGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { DirectionalPlanksDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var woods = Set<Position>()
    
    override func copy() -> DirectionalPlanksGameState {
        let v = DirectionalPlanksGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: DirectionalPlanksGameState) -> DirectionalPlanksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: DirectionalPlanksGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> GridDotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    private func isValidMove(move: inout DirectionalPlanksGameMove) -> Bool {
        !(move.p.row == rows - 1 && move.dir == 2 ||
            move.p.col == cols - 1 && move.dir == 1)
    }
    
    override func setObject(move: inout DirectionalPlanksGameMove) -> GameOperationType {
        guard isValidMove(move: &move) else { return .invalid }
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let p = move.p
        let dir = move.dir, dir2 = (dir + 2) % 4
        f(o1: &self[p][dir], o2: &self[p + DirectionalPlanksGame.offset[dir]][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout DirectionalPlanksGameMove) -> GameOperationType {
        guard isValidMove(move: &move) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            default:
                return o
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 5/Directional Planks

        Summary
        Can't move

        Description
        1. Divide the board in areas of three tiles (planks_offset).
        2. Each plank contains one number and the number tells you how many
           directions the Plank can move, when the board is completed.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
            }
        }
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for i in 0..<4 {
                    guard self[p + DirectionalPlanksGame.offset2[i]][DirectionalPlanksGame.dirs[i]] != .line else {continue}
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p + DirectionalPlanksGame.offset[i]]!)
                }
            }
        }
        woods.removeAll()
        var planks = [[Position]]()
        var pos2plank = [Position: Int]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let rng = area.filter { game.nails.contains($0) }
            if rng.isEmpty {continue}
            // 2. Planks are areas of exactly three cells and can be straight or angled.
            guard area.count == 3 else { isSolved = false; continue }
            // 1. Locate some pieces of wood (Planks).
            // 3. Each Plank contains one nail.
            guard rng.count == 1 else { isSolved = false; continue }
            let n = planks.count
            planks.append(area)
            for p in area {
                pos2plank[p] = n
                woods.insert(p)
            }
        }
        // 4. After finding all the Planks, it must be possible to move each piece
        //    by one cell in at least one direction.
        for plank in planks {
            if !DirectionalPlanksGame.offset.contains(where: { os in
                let area = plank.map { $0 + os }
                return area.testAll { [unowned self] in plank.contains($0) || !woods.contains($0) }
            }) { isSolved = false }
        }
    }
}
