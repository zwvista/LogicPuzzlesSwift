//
//  FarmerGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FarmerGameState: GridGameState<FarmerGameMove> {
    var game: FarmerGame {
        get { getGame() as! FarmerGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FarmerDocument.sharedInstance }
    var objArray = [FarmerObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> FarmerGameState {
        let v = FarmerGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FarmerGameState) -> FarmerGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FarmerGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> FarmerObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FarmerObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout FarmerGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FarmerGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: .fv1
        case .fv1: .fv2
        case .fv2: .fv3
        case .fv3: .empty
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 2/Farmer

        Summary
        Vegetable Gardener

        Description
        1. A Farmer has a scientific way to work his field:
        2. He plants three types of fruits or vegetables.
        3. Each area must contain either three identical plants or three different plants.
        4. When two plants are orthogonally adjacent across an area, they must be different.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        for area in game.areas {
            let objSet = Set(area.map { self[$0] })
            guard !objSet.contains(.empty) else { isSolved = false; continue }
            let cnt = objSet.count
            // 3. Each area must contain either three identical plants or three different plants.
            if !(cnt == 1 || cnt == 3) {
                isSolved = false
                for p in area { pos2state[p] = .error }
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let area1 = game.pos2area[p]!
                guard o != .empty else {continue}
                // 4. When two plants are orthogonally adjacent across an area, they must be different.
                for os in FarmerGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2) else {continue}
                    if self[p2] == o && area1 != game.pos2area[p2]! {
                        isSolved = false
                        pos2state[p] = .error
                    }
                }
            }
        }
    }
}
