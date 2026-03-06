//
//  LandscapesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LandscapesGameState: GridGameState<LandscapesGameMove> {
    var game: LandscapesGame {
        get { getGame() as! LandscapesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LandscapesDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: AllowedObjectState]()
    var invalidCrossroads = [Position]()
    
    override func copy() -> LandscapesGameState {
        let v = LandscapesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LandscapesGameState) -> LandscapesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: LandscapesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout LandscapesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == LandscapesGame.PUZ_EMPTY && self[p] != move.obj else { return .invalid }
        for p2 in game.areas[game.pos2area[p]!] {
            self[p2] = move.obj
        }
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout LandscapesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == LandscapesGame.PUZ_EMPTY else { return .invalid }
        let o = self[p]
        move.obj = o == 9 ? LandscapesGame.PUZ_EMPTY : o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 5/Crossroads X

        Summary
        Cross at Ten

        Description
        1. Place a number in each region from 0 to 9.
        2. When four regions borders intersect (a spot where four lines meet),
           the sum of those 4 regions must be 10.
        3. No two orthogonally adjacent regions can have the same number.
    */
    private func updateIsSolved() {
        isSolved = true
        // 2. When four regions borders intersect (a spot where four lines meet),
        //    the sum of those 4 regions must be 10.
        invalidCrossroads = game.crossroads.filter { p in
            let rng = LandscapesGame.offset3.map { p + $0 }
            return !(rng.allSatisfy({ self[$0] != LandscapesGame.PUZ_EMPTY }) && rng.reduce(0) { $0 + self[$1] } == game.sum)
        }
        if !invalidCrossroads.isEmpty { isSolved = false }
        // 3. No two orthogonally adjacent regions can have the same number.
        for (i, area) in game.areas.enumerated() {
            let n = self[area[0]]
            let areas = game.area2areas[i]
                .map { self.game.areas[$0] }
                .filter { self[$0[0]] == n }
            if areas.isEmpty {
                for p in area { pos2state[p] = .normal }
            } else {
                isSolved = false
                for area2 in [area] + areas {
                    for p in area2 { pos2state[p] = .error }
                }
            }
        }
    }
}
