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
    var objArray = [LandscapesObject]()
    var pos2state = [Position: AllowedObjectState]()
    
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
    
    subscript(p: Position) -> LandscapesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LandscapesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout LandscapesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty && self[p] != move.obj else { return .invalid }
        for p2 in game.areas[game.pos2area[p]!] {
            self[p2] = move.obj
        }
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout LandscapesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = switch (o) {
        case .empty: .tree
        case .tree: .sand
        case .sand: .rock
        case .rock: .water
        case .water: .empty
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 16/Landscapes

        Summary
        Forests, Deserts, Oceans, Mountains

        Description
        1. Identify the landscape in every region, choosing between trees, sand,
           water and rocks.
        2. Two regions can't have the same landscape if they touch, not even
           diagonally.
    */
    private func updateIsSolved() {
        isSolved = true
        // 2. Two regions can't have the same landscape if they touch, not even
        //    diagonally.
        for (i, indexes) in game.area2areas.enumerated() {
            let area = game.areas[i]
            let o = self[area[0]]
            guard o != .empty else { isSolved = false; continue }
            let s: AllowedObjectState = (indexes.contains {
                o == self[game.areas[$0][0]]
            }) ? .error : .normal
            for p in area { pos2state[p] = s }
            if s == .error { isSolved = false }
        }
    }
}
