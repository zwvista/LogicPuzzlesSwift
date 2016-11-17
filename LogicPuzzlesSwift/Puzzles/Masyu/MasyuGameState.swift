//
//  MasyuGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MasyuGameState: CellsGameState {
    var game: MasyuGame {return gameBase as! MasyuGame}
    var objArray = [MasyuObject]()
    var pos2state = [Position: HintState]()
    var options: MasyuGameProgress { return MasyuDocument.sharedInstance.gameProgress }
    
    override func copy() -> MasyuGameState {
        let v = MasyuGameState(game: gameBase)
        return setup(v: v)
    }
    func setup(v: MasyuGameState) -> MasyuGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: CellsGameBase) {
        super.init(game: game)
        objArray = Array<MasyuObject>(repeating: MasyuObject(repeating: false, count: 4), count: rows * cols)
    }
    
    subscript(p: Position) -> MasyuObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> MasyuObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout MasyuGameMove) -> Bool {
        let p = move.p, dir = move.dir
        let p2 = p + MasyuGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else {return false}
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        return true
    }
    
    
    private func updateIsSolved() {
        isSolved = true
        isSolved = false
    }
}
