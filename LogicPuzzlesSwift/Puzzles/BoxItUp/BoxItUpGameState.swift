//
//  BoxItUpGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BoxItUpGameState: CellsGameState, BoxItUpMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: BoxItUpGame {
        get {return getGame() as! BoxItUpGame}
        set {setGame(game: newValue)}
    }
    var objArray = [BoxItUpObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> BoxItUpGameState {
        let v = BoxItUpGameState(game: game)
        return setup(v: v)
    }
    func setup(v: BoxItUpGameState) -> BoxItUpGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: BoxItUpGame) {
        super.init(game: game);
        objArray = Array<BoxItUpObject>(repeating: Array<Bool>(repeating: false, count: 4), count: rows * cols)
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
    }
    
    subscript(p: Position) -> BoxItUpObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> BoxItUpObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout BoxItUpGameMove) -> Bool {
        let p = move.p, dir = move.dir
        let p2 = p + BoxItUpGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && !(game[p][dir] && self[p][dir]) else {return false}
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return true
    }
    
    private func updateIsSolved() {
        isSolved = true
    }
}
