//
//  MosaikGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MosaikGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: MosaikGame {
        get {return getGame() as! MosaikGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: MosaikDocument { return MosaikDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return MosaikDocument.sharedInstance }
    var objArray = [MosaikObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> MosaikGameState {
        let v = MosaikGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MosaikGameState) -> MosaikGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: MosaikGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MosaikObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> MosaikObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> MosaikObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout MosaikGameMove) -> Bool {
        if self[move.p] == move.obj {return false}
        self[move.p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout MosaikGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: MosaikObject) -> MosaikObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .filled
            case .filled:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .filled : .empty
            }
        }
        let o = f(o: self[move.p])
        move.obj = o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 4/Mosaik

        Summary
        Paint the mosaic, filling squares with the numbered hints

        Description
        1. In Mosaik, there is a hidden image which can be discovered using the
           numbered hints.
        2. A number tells you how many tiles must be filled in the 3*3 area formed
           by the tile itself and the ones surrounding it.
        3. Thus the numbers can go from 0, where no tiles is filled, to 9, where
           every tile is filled in a 3*3 area around the tile with the number.
        4. Every number in between denotes that some of the tiles in that 3*3
           area are filled and some are not.
    */
    private func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2hint {
            var n1 = 0
            for os in MosaikGame.offset {
                let p2 = p + os
                if isValid(p: p2), self[p2] == .filled {n1 += 1}
            }
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
    }
}
