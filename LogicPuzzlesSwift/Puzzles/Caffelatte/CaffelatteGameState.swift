//
//  CaffelatteGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CaffelatteGameState: GridGameState<CaffelatteGameMove> {
    var game: CaffelatteGame {
        get { getGame() as! CaffelatteGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CaffelatteDocument.sharedInstance }
    var objArray = [CaffelatteObject]()
    
    override func copy() -> CaffelatteGameState {
        let v = CaffelatteGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CaffelatteGameState) -> CaffelatteGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CaffelatteGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CaffelatteObject>(repeating: CaffelatteObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> CaffelatteObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CaffelatteObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CaffelatteGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + CaffelatteGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/Caffelatte

        Summary
        Cows and Coffee

        Description
        1. Make Cappuccino by linking each cup to one or more coffee beans and cows.
        2. Links must be straight lines, not crossing each other.
        3. To each cup there must be linked an equal number of beans and cows. At
           least one of each.
        4. When linking multiple beans and cows, you can also link cows to cows and
           beans to beans, other than linking them to the cup.
    */
    private func updateIsSolved() {
        isSolved = true
        var coffeeArray = [Position]()
        var sugarArray = [Position]()
        var emptyArray = [Position]()
        var ch2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let ch = game[p]
                let dirs = (0..<4).filter { o[$0] }
                ch2dirs[p] = dirs
                let cnt = dirs.count
                switch ch {
                case CaffelatteGame.PUZ_CUP:
                    guard cnt == 1 else { isSolved = false; return }
                    coffeeArray.append(p)
                case CaffelatteGame.PUZ_BEAN:
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
            let i = ch2dirs[p]!.first!
            var os = CaffelatteGame.offset[i]
            var p2 = p + os
            var dirs = [Int]()
            while true {
                let ch = game[p2]
                guard ch == " " else { isSolved = false; return }
                emptyArray2.append(p2)
                let j = (i + 2) % 4
                dirs = ch2dirs[p2]!
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
                os = CaffelatteGame.offset[i]
                var p3 = p2 + os
                while true {
                    let ch = game[p3]
                    guard ch == " " || ch == CaffelatteGame.PUZ_BEAN else { isSolved = false; return }
                    var dirs2 = ch2dirs[p3]!
                    let j = (i + 2) % 4
                    guard dirs2.contains(j) else { isSolved = false; return }
                    if ch == CaffelatteGame.PUZ_BEAN {
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
