//
//  FloorPlanGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FloorPlanGameState: GridGameState<FloorPlanGameMove> {
    var game: FloorPlanGame {
        get { getGame() as! FloorPlanGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FloorPlanDocument.sharedInstance }
    var objArray = [Int]()
    var pos2horzState = [Position: HintState]()
    var pos2vertState = [Position: HintState]()

    override func copy() -> FloorPlanGameState {
        let v = FloorPlanGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FloorPlanGameState) -> FloorPlanGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2horzState = pos2horzState
        v.pos2vertState = pos2vertState
        return v
    }
    
    required init(game: FloorPlanGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        for r in 0..<rows {
            for c in 0..<cols {
                self[r, c] = game[r, c]
            }
        }
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

    override func setObject(move: inout FloorPlanGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FloorPlanGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 else { return .invalid }
        let o = self[p]
        move.obj = (o + 1) % 10
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 1/Floor Plan

        Summary
        Blueprints to fill in

        Description
        1. The board represents a blueprint of an office floor.
        2. Cells with a number represent an office. On the floor every office is
           interconnected and can be reached by every other office.
        3. The number on a cell indicates how many offices it connects to. No two
           offices with the same number can be adjacent.
    */
    private func updateIsSolved() {
        isSolved = true
        for i in 0..<game.areas.count {
            let a = game.areas[i]
            let nums = a.map { self[$0] }
            let nums2 = Set<Int>(nums).sorted()
            // 2. Each 'word' is formed by an uninterrupted sequence of numbers,
            // but in any order.
            let s: HintState = nums2.first! == 0 ? .normal : nums2.count == nums.count ? .complete : .error
            for p in a {
                if i < game.horzAreaCount {
                    pos2horzState[p] = s
                } else {
                    pos2vertState[p] = s
                }
            }
            if s != .complete { isSolved = false }
        }
    }
}
