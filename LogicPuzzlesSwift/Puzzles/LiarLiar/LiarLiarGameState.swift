//
//  LiarLiarGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LiarLiarGameState: GridGameState<LiarLiarGameMove> {
    var game: LiarLiarGame {
        get { getGame() as! LiarLiarGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LiarLiarDocument.sharedInstance }
    var objArray = [LiarLiarObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> LiarLiarGameState {
        let v = LiarLiarGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LiarLiarGameState) -> LiarLiarGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: LiarLiarGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LiarLiarObject>(repeating: LiarLiarObject(), count: rows * cols)
        for (p, _) in game.pos2hint {
            self[p] = .hint()
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> LiarLiarObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LiarLiarObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout LiarLiarGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game.pos2hint[p] == nil, String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout LiarLiarGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: LiarLiarObject) -> LiarLiarObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .marked
            case .marked:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .marked : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) && game.pos2hint[p] == nil else { return .invalid }
        let o = self[p]
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 2/Liar Liar

        Summary
        Tiles on fire

        Description
        1. Mark some tiles according to these rules:
        2. Cells with numbers are never marked.
        3. A number in a cell indicates how many marked cells must be placed.
           adjacent to its four sides.
        4. However, in each region there is one (and only one) wrong number
           (it shows a wrong amount of marked cells).
        5. Two marked cells must not be orthogonally adjacent.
        6. All of the non-marked cells must be connected.
    */
    private func updateIsSolved() {
        isSolved = true
    }
}
