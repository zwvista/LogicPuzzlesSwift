//
//  ShopAndGasGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ShopAndGasGameState: GridGameState<ShopAndGasGameMove> {
    var game: ShopAndGasGame {
        get { getGame() as! ShopAndGasGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ShopAndGasDocument.sharedInstance }
    var objArray = [ShopAndGasObject]()
    
    override func copy() -> ShopAndGasGameState {
        let v = ShopAndGasGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ShopAndGasGameState) -> ShopAndGasGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ShopAndGasGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ShopAndGasObject>(repeating: ShopAndGasObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> ShopAndGasObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ShopAndGasObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ShopAndGasGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + ShopAndGasGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 10/Shop & Gas

        Summary
        A Hard day at shopping!

        Description
        1. In Shop & Gas you take the typical day at shopping. By the way:
           you just bought a new hyper-ecological car.
        2. This car goes on a ultra-green combustible, which is the saviour
           of the environment. It costs close to zero, it does not pollute
           and is found in abundance everywhere.
        3. The only small problem is that the car consumes about 10 liter
           per Km. Yes, that's a problem.
        4. So while shopping you have to constantly refuel your car. Thus,
           Shop & Gas rules are as follows:
        5. You start from your house. Right away, you're low on fuel so you
           must pass a fuel station.
        6. All these prototype fuel stations are shaped like corners. Don't
           ask why. You just have to turn on those tiles.
        7. Each time you pass a gas station, you then have to go shopping.
        8. Shopping malls are a lot more consumer friendly and have straight
           roads. So you have to go straight on those tiles.
        9. After a shopping mall you are almost empty again. The next thing
           you must pass is a gas station. Then shopping, gas, etc.
        10.After you passed all the shopping malls and gas station, you have
           to go back to your house, forming a closed path.
        11.The last thing you have to pass before going back home, is a gas
           station.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = game[p]
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    pos2dirs[p] = dirs
                    if ch == ShopAndGasGame.PUZ_BLACK_PEARL {
                        // 4. Lines passing through Black Pearls must do a 90 degree turn in them.
                        guard dirs[1] - dirs[0] != 2 else { isSolved = false; return }
                    } else if ch == ShopAndGasGame.PUZ_WHITE_PEARL {
                        // 3. Lines passing through White Pearls must go straight through them.
                        guard dirs[1] - dirs[0] == 2 else { isSolved = false; return }
                    }
                } else if !(dirs.isEmpty && ch == " ") {
                    // 1. The goal is to draw a single Loop(Necklace) through every circle(Pearl)
                    //    that never branches-off or crosses itself.
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
            p2 += ShopAndGasGame.offset[n]
            guard p2 != p else {break}
        }
        // 3. At least at one side of the White Pearl(or both), they must do a 90 degree turn.
        // 4. Lines passing through Black Pearls must go straight in the next tile in both directions.
        // 5. Lines passing where there are no Pearls can do what they want.
        if !pos2dirs2.testAll({ p, dirs in
            let ch = game[p]
            guard ch != " " else { return true }
            let turns = dirs.reduce(0) { acc, d in
                let dirs2 = pos2dirs[p + ShopAndGasGame.offset[d]]!
                return acc + (dirs2[1] - dirs2[0] != 2 ? 1 : 0)
            }
            return ch == ShopAndGasGame.PUZ_BLACK_PEARL && turns == 0 || ch == ShopAndGasGame.PUZ_WHITE_PEARL && turns > 0
        }) { isSolved = false }
    }
}
