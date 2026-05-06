//
//  HedgeMazeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HedgeMazeGameState: GridGameState<HedgeMazeGameMove> {
    var game: HedgeMazeGame {
        get { getGame() as! HedgeMazeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { HedgeMazeDocument.sharedInstance }
    var objArray = [HedgeMazeObject]()
    var invalid2x2Squares = [Position]()

    override func copy() -> HedgeMazeGameState {
        let v = HedgeMazeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: HedgeMazeGameState) -> HedgeMazeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: HedgeMazeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> HedgeMazeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> HedgeMazeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout HedgeMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.iconlessAreas.contains(game.pos2area[p]!), self[p] != move.obj else { return .invalid }
        for p2 in game.areas[game.pos2area[p]!] {
            self[p2] = move.obj
        }
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout HedgeMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.iconlessAreas.contains(game.pos2area[p]!) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .hedge
        case .hedge: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .hedge : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 6/Hedge Maze

        Summary
        Wendy ?

        Description
        1. Fill some of the empty areas with hedges, thus forming a maze.
        2. The maze should be one tile wide. It can branch itself, but not close in a loop.
        3. There should be a path between the two gates. This path should pass on
           all the steps and not on any fountain.
        4. On the board there can't be a 2x2 area all made of hedges or all without hedges (empty).
        5. Tiles with any icon count as empty and cannot be filled with hedges.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        // 4. On the board there can't be a 2x2 area all made of hedges or all without hedges (empty).
        // 5. Tiles with any icon count as empty and cannot be filled with hedges.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                var hedgeAreas = Set<Int>()
                var iconAreas = Set<Int>()
                var emptyAreas = Set<Int>()
                for os in HedgeMazeGame.offset3 {
                    let p2 = p + os
                    let id = game.pos2area[p2]!
                    let o = self[p2]
                    if o == .hedge {
                        hedgeAreas.insert(id)
                    } else if !game.iconlessAreas.contains(id) {
                        iconAreas.insert(id)
                    } else {
                        emptyAreas.insert(id)
                    }
                }
                if hedgeAreas.isEmpty || iconAreas.isEmpty && emptyAreas.isEmpty {
                    invalid2x2Squares.append(p + Position.SouthEast); isSolved = false
                } else if allowedObjectsOnly && iconAreas.isEmpty && emptyAreas.count == 1 {
                    let area = game.areas[emptyAreas.first!]
                    for p2 in area { self[p2] = .forbidden }
                }
            }
        }
        guard isSolved else {return}
        // 2. The maze should be one tile wide. It can branch itself, but not close in a loop.
        var rng = Set<Position>()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] != .hedge {
                    rng.insert(p)
                }
            }
        }
        var moves = Set<Position>()
        func dfs(p: Position, n: Int) -> Bool {
            guard moves.insert(p).inserted else { return false }
            for i in 0..<4 {
                if i == n {continue}
                let p2 = p + HedgeMazeGame.offset[i]
                guard rng.contains(p2) else {continue}
                guard dfs(p: p2, n: (i + 2) % 4) else { return false }
            }
            return true
        }
        guard dfs(p: rng.first!, n: -1) && moves.count == rng.count else { isSolved = false; return }
        // 3. There should be a path between the two gates. This path should pass on
        //    all the steps and not on any fountain.
        let gate1 = game.gates[0], gate2 = game.gates[1]
        moves.removeAll()
        func dfs2(p: Position, n: Int) -> Bool {
            let o = self[p]
            guard o != .fountain else { return false }
            moves.insert(p)
            if p == gate2 { return true }
            for i in 0..<4 {
                if i == n {continue}
                let p2 = p + HedgeMazeGame.offset[i]
                guard rng.contains(p2) else {continue}
                if dfs2(p: p2, n: (i + 2) % 4) { return true }
            }
            moves.remove(p)
            return false
        }
        if !(dfs2(p: gate1, n: -1) && game.steps.allSatisfy {
            moves.contains($0)
        }) { isSolved = false }
    }
}
