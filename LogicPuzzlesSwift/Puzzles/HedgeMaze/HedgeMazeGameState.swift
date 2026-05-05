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
    var pos2state = [Position: AllowedObjectState]()

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
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout HedgeMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: .up
        case .up: .right
        case .right: .down
        case .down: .left
        case .left: .empty
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
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 3. Arrows in an area should all be different, i.e. there can't be two
        //    similar arrows in an area.
        for area in game.areas {
            var symbol2range = [HedgeMazeObject: [Position]]()
            for p in area { symbol2range[self[p], default: []].append(p) }
            for (_, range) in symbol2range where range.count > 1 {
                isSolved = false
                for p in range { pos2state[p] = .error }
            }
            if symbol2range.keys.contains(HedgeMazeObject.empty) { isSolved = false }
        }
        guard isSolved else {return}
        // 1. All the roads lead to HedgeMaze.
        // 2. Hence you should fill the remaining spaces with arrows and in the
        //    end, starting at any tile and following the arrows, you should get
        //    at the HedgeMaze icon.
        var validRange = Set<Position>()
        var invalidRange = Set<Position>()
        for r in 0..<rows {
            for c in 0..<cols {
                var p = Position(r, c)
                var range = Set<Position>()
                while true {
                    let o = self[p]
                    if o == .rome || validRange.contains(p) {
                        for p2 in range { validRange.insert(p2) }
                        break
                    }
                    if !isValid(p: p) || invalidRange.contains(p) || range.contains(p) {
                        isSolved = false
                        for p2 in range { invalidRange.insert(p2) }
                        break
                    }
                    range.insert(p)
                    let os = HedgeMazeGame.offset[o.rawValue - 2]
                    p += os
                }
            }
        }
        for p in invalidRange { pos2state[p] = .error }
    }
}
