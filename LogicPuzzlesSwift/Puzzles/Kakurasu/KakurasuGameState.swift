//
//  KakurasuGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class KakurasuGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: KakurasuGame {
        get {getGame() as! KakurasuGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: KakurasuDocument { return KakurasuDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return KakurasuDocument.sharedInstance }
    var objArray = [KakurasuObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> KakurasuGameState {
        let v = KakurasuGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: KakurasuGameState) -> KakurasuGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: KakurasuGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<KakurasuObject>(repeating: .empty, count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows * 2)
        col2state = Array<HintState>(repeating: .normal, count: cols * 2)
        updateIsSolved()
    }
    
    subscript(p: Position) -> KakurasuObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> KakurasuObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func pos2state(row: Int, col: Int) -> HintState {
        return row == 0 && 1..<cols - 1 ~= col ? col2state[col * 2] :
            row == rows - 1 && 1..<cols - 1 ~= col ? col2state[col * 2 + 1] :
            col == 0 && 1..<rows - 1 ~= row ? row2state[row * 2] :
            col == cols - 1 && 1..<rows - 1 ~= row ? row2state[row * 2 + 1] :
            .normal
    }
    
    func setObject(move: inout KakurasuGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout KakurasuGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: KakurasuObject) -> KakurasuObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .cloud
            case .cloud:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .cloud : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 8/Kakurasu

        Summary
        Cloud Kakuro on a Skyscraper

        Description
        1. On the bottom and right border, you see the value of (respectively)
           the columns and rows.
        2. On the other borders, on the top and the left, you see the hints about
           which tile have to be filled on the board. These numbers represent the
           sum of the values mentioned above.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if self[r, c] == .forbidden {self[r, c] = .empty}
            }
        }
        for r in 1..<rows - 1 {
            // 1. On the bottom and right border, you see the value of (respectively)
            // the rows.
            let n2 = game.row2hint[r * 2]
            var n1 = 0
            for c in 1..<cols - 1 {
                if self[r, c] == .cloud {
                    // 2. On the other borders, on the top and the left, you see the hints about
                    // which tile have to be filled on the board.
                    n1 += game.col2hint[c * 2 + 1]
                }
            }
            // 2. These numbers represent the sum of the values mentioned above.
            let s: HintState = n1 == 0 ? .normal : n1 == n2 ? .complete : .error
            row2state[r * 2] = s
            if s != .complete {isSolved = false}
            if n1 >= n2 && allowedObjectsOnly {
                for c in 1..<cols - 1 {
                    switch self[r, c] {
                    case .empty, .marker:
                        self[r, c] = .forbidden
                    default:
                        break
                    }
                }
            }
        }
        for c in 1..<cols - 1 {
            // 1. On the bottom and right border, you see the value of (respectively)
            // the columns.
            let n2 = game.col2hint[c * 2]
            var n1 = 0
            for r in 1..<rows - 1 {
                if self[r, c] == .cloud {
                    // 2. On the other borders, on the top and the left, you see the hints about
                    // which tile have to be filled on the board.
                    n1 += game.row2hint[r * 2 + 1]
                }
            }
            // 2. These numbers represent the sum of the values mentioned above.
            let s: HintState = n1 == 0 ? .normal : n1 == n2 ? .complete : .error
            col2state[c * 2] = s
            if s != .complete {isSolved = false}
            if n1 >= n2 && allowedObjectsOnly {
                for r in 1..<rows - 1 {
                    switch self[r, c] {
                    case .empty, .marker:
                        self[r, c] = .forbidden
                    default:
                        break
                    }
                }
            }
        }
    }
}
