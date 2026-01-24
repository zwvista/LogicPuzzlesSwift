//
//  CoffeeAndSugarGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CoffeeAndSugarGameState: GridGameState<CoffeeAndSugarGameMove> {
    var game: CoffeeAndSugarGame {
        get { getGame() as! CoffeeAndSugarGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CoffeeAndSugarDocument.sharedInstance }
    var objArray = [CoffeeAndSugarObject]()
    
    override func copy() -> CoffeeAndSugarGameState {
        let v = CoffeeAndSugarGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CoffeeAndSugarGameState) -> CoffeeAndSugarGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CoffeeAndSugarGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CoffeeAndSugarObject>(repeating: CoffeeAndSugarObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> CoffeeAndSugarObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CoffeeAndSugarObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CoffeeAndSugarGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + CoffeeAndSugarGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 17/Coffee And Sugar

        Summary
        How many ?

        Description
        1. Link the Coffee cup with two sugar cubes.
        2. The link should be T-shaped: two sugar cubes must be connected with a straight
           line and the cup forms the middle segment.

        Double Espresso Variant
        3. In some levels (when notified in the top right corner), this variant means you
           can also link two coffees and one sugar. Both configurations are good.
    */
    private func updateIsSolved() {
        isSolved = true
        var coffeeArray = [Position]()
        var sugarArray = [Position]()
        var emptyArray = [Position]()
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let ch = game[p]
                let dirs = (0..<4).filter { o[$0] }
                pos2dirs[p] = dirs
                let cnt = dirs.count
                switch ch {
                case CoffeeAndSugarGame.PUZ_COFFEE:
                    guard cnt == 1 else { isSolved = false; return }
                    coffeeArray.append(p)
                case CoffeeAndSugarGame.PUZ_SUGAR:
                    guard cnt == 1 else { isSolved = false; return }
                    sugarArray.append(p)
                default:
                    guard [0, 2, 3].contains(cnt) else { isSolved = false; return }
                    if cnt != 0 { emptyArray.append(p) }
                }
            }
        }
        var sugarArray2 = [Position]()
        var emptyArray2 = [Position]()
        for p in coffeeArray {
            let i = pos2dirs[p]!.first!
            var os = CoffeeAndSugarGame.offset[i]
            var p2 = p + os
            var dirs = [Int]()
            while true {
                let ch = game[p2]
                guard ch == " " else { isSolved = false; return }
                emptyArray2.append(p2)
                let j = (i + 2) % 4
                dirs = pos2dirs[p2]!
                guard dirs.contains(j) else { isSolved = false; return }
                dirs = dirs.filter { $0 != j }
                if dirs.count == 2 {
                    guard !dirs.contains(i) else { isSolved = false; return }
                    break
                }
                let k = dirs.first!
                guard k == i else { isSolved = false; return }
                p2 += os
            }
            for i in dirs {
                os = CoffeeAndSugarGame.offset[i]
                var p3 = p2 + os
                while true {
                    let ch = game[p3]
                    guard ch == " " || ch == CoffeeAndSugarGame.PUZ_SUGAR else { isSolved = false; return }
                    var dirs2 = pos2dirs[p3]!
                    let j = (i + 2) % 4
                    guard dirs2.contains(j) else { isSolved = false; return }
                    if ch == CoffeeAndSugarGame.PUZ_SUGAR {
                        sugarArray2.append(p3)
                        break
                    }
                    emptyArray2.append(p3)
                    dirs2 = dirs2.filter { $0 != j }
                    guard dirs2.count == 1 else { isSolved = false; return }
                    let k = dirs2.first!
                    guard k == i else { isSolved = false; return }
                    p3 += os
                }
            }
        }
        if (sugarArray.count, emptyArray.count) != (sugarArray2.count, emptyArray2.count) { isSolved = false }
    }
}
