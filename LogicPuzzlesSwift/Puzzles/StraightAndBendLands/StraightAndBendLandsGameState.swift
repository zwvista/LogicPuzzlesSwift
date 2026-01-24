//
//  StraightAndBendLandsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class StraightAndBendLandsGameState: GridGameState<StraightAndBendLandsGameMove> {
    var game: StraightAndBendLandsGame {
        get { getGame() as! StraightAndBendLandsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { StraightAndBendLandsDocument.sharedInstance }
    var objArray = [StraightAndBendLandsObject]()

    override func copy() -> StraightAndBendLandsGameState {
        let v = StraightAndBendLandsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: StraightAndBendLandsGameState) -> StraightAndBendLandsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: StraightAndBendLandsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<StraightAndBendLandsObject>(repeating: StraightAndBendLandsObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> StraightAndBendLandsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> StraightAndBendLandsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout StraightAndBendLandsGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + StraightAndBendLandsGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && game[p] != StraightAndBendLandsGame.PUZ_TREE && game[p2] != StraightAndBendLandsGame.PUZ_TREE else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 3/Straight and Bend Lands

        Summary
        Our land of curves is better than your straight one!

        Description
        1. This odd nation is divided into two types of regions. One where roads
           always turn on villages, and one where roads always go straight!
        2. Draw a loop that goes through villages (houses), but avoid trees.
        3. While passing on villages, the road might turn or not, but if it turns
           then the road will turn on all villages in that region.
        4. Conversely if it goes straight, all villages of that region will have
           the road go straight through them.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    // 2. Draw a loop that goes through villages (houses), but avoid trees.
                    pos2dirs[p] = dirs
                } else if !(dirs.isEmpty && game[p] == StraightAndBendLandsGame.PUZ_TREE) {
                    // The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        let pos2dirs2 = pos2dirs
        // Check the loop
        guard let p = pos2dirs.keys.first else { isSolved = false; return }
        var p2 = p
        var n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += StraightAndBendLandsGame.offset[n]
            guard p2 != p else {break}
        }
        // 1. This odd nation is divided into two types of regions. One where roads
        //    always turn on villages, and one where roads always go straight!
        // 3. While passing on villages, the road might turn or not, but if it turns
        //    then the road will turn on all villages in that region.
        // 4. Conversely if it goes straight, all villages of that region will have
        //    the road go straight through them.
        if !(game.areas.allSatisfy({ area in
            let rng = area.filter { game[$0] == StraightAndBendLandsGame.PUZ_HOUSE }
            return rng.allSatisfy({
                let dirs = pos2dirs2[$0]!
                return dirs[1] - dirs[0] == 2
            }) || rng.allSatisfy({
                let dirs = pos2dirs2[$0]!
                return dirs[1] - dirs[0] != 2
            })
        })) { isSolved = false }
    }
}
