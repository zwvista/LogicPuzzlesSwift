//
//  PointingGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PointingGameState: GridGameState<PointingGameMove> {
    var game: PointingGame {
        get { getGame() as! PointingGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PointingDocument.sharedInstance }
    var markedArrows = Set<Position>()
    var nonPointingArrows = Set<Position>()

    override func copy() -> PointingGameState {
        let v = PointingGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PointingGameState) -> PointingGameState {
        _ = super.setup(v: v)
        v.markedArrows = markedArrows
        return v
    }
    
    required init(game: PointingGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        updateIsSolved()
    }

    override func setObject(move: inout PointingGameMove) -> GameOperationType {
        let p = move.p
        guard game.isValid(p: p) else { return .invalid }
        if !markedArrows.insert(p).inserted { markedArrows.remove(p) }
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout PointingGameMove) -> GameOperationType {
        setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Pointing

        Summary
        Are you pointing to me?

        Description
        1. Mark some arrows so that each arrow points to exactly one marked arrow.
    */
    private func updateIsSolved() {
        isSolved = true
        nonPointingArrows = Set(game.arrow2rng.filter { (_, rng) in rng.allSatisfy { !markedArrows.contains($0) } }.keys)
        if !nonPointingArrows.isEmpty { isSolved = false }
    }
}
