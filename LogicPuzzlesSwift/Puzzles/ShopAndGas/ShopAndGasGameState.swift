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
                    if ch == ShopAndGasGame.PUZ_GAS {
                        // 6. All these prototype fuel stations are shaped like corners. Don't
                        //    ask why. You just have to turn on those tiles.
                        guard dirs[1] - dirs[0] != 2 else { isSolved = false; return }
                    } else if ch == ShopAndGasGame.PUZ_SHOP {
                        // 8. Shopping malls are a lot more consumer friendly and have straight
                        //    roads. So you have to go straight on those tiles.
                        guard dirs[1] - dirs[0] == 2 else { isSolved = false; return }
                    }
                } else if !(dirs.isEmpty && ch == " ") {
                    // 5. You start from your house.
                    // 11.The last thing is going back home.
                    // 10.After you passed all the shopping malls and gas station, you have
                    //    to go back to your house, forming a closed path.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        let p = game.home
        guard pos2dirs.keys.contains(p) else { isSolved = false; return }
        var p2 = p
        var n = -1
        var ch = game[p]
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += ShopAndGasGame.offset[n]
            let ch2 = game[p2]
            if ch2 != " " {
                // 5. You start from your house. Right away, you're low on fuel so you
                //    must pass a fuel station.
                // 7. Each time you pass a gas station, you then have to go shopping.
                // 9. After a shopping mall you are almost empty again. The next thing
                //    you must pass is a gas station. Then shopping, gas, etc.
                // 11.The last thing you have to pass before going back home, is a gas
                //    station.
                guard (ch == ShopAndGasGame.PUZ_HOME || ch == ShopAndGasGame.PUZ_SHOP) && ch2 == ShopAndGasGame.PUZ_GAS || ch == ShopAndGasGame.PUZ_GAS && (ch2 == ShopAndGasGame.PUZ_SHOP || ch2 == ShopAndGasGame.PUZ_HOME) else { isSolved = false; return }
                ch = ch2
            }
            guard p2 != p else {break}
        }
    }
}
