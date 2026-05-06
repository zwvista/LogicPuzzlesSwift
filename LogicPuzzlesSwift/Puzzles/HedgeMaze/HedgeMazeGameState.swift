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
        isSolved = true
        // 4. On the board there can't be a 2x2 area all made of hedges or all without hedges (empty).
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if (HedgeMazeGame.offset3.map { p + $0 }.allSatisfy { self[$0] == .hedge } ||
                    HedgeMazeGame.offset3.map { p + $0 }.allSatisfy { self[$0] != .hedge }) {
                    invalid2x2Squares.append(p + Position.SouthEast); isSolved = false
                }
            }
        }
        guard isSolved else {return}
    }
}
