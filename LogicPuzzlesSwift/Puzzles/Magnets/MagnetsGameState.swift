//
//  MagnetsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MagnetsGameState: CellsGameState, MagnetsMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: MagnetsGame {
        get {return getGame() as! MagnetsGame}
        set {setGame(game: newValue)}
    }
    var objArray = [MagnetsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> MagnetsGameState {
        let v = MagnetsGameState(game: game)
        return setup(v: v)
    }
    func setup(v: MagnetsGameState) -> MagnetsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: MagnetsGame) {
        super.init(game: game);
        objArray = Array<MagnetsObject>(repeating: MagnetsObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows * 2)
        col2state = Array<HintState>(repeating: .normal, count: cols * 2)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MagnetsObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> MagnetsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout MagnetsGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && !game.singles.contains(p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout MagnetsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: MagnetsObject) -> MagnetsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .positive
            case .positive:
                return .negative
            case .negative:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .positive : .empty
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            var (np1, nn1) = (0, 0)
            let (np2, nn2) = (game.row2hint[r * 2], game.row2hint[r * 2 + 1])
            for c in 0..<cols {
                switch self[r, c] {
                case .positive:
                    np1 += 1
                case .negative:
                    nn1 += 1
                default:
                    break
                }
            }
            row2state[r * 2] = np1 < np2 ? .normal : np1 == np2 ? .complete : .error
            row2state[r * 2 + 1] = nn1 < nn2 ? .normal : nn1 == nn2 ? .complete : .error
            if np1 != np2 || nn1 != nn2 {isSolved = false}
        }
        for c in 0..<cols {
            var (np1, nn1) = (0, 0)
            let (np2, nn2) = (game.col2hint[c * 2], game.col2hint[c * 2 + 1])
            for r in 0..<rows {
                switch self[r, c] {
                case .positive:
                    np1 += 1
                case .negative:
                    nn1 += 1
                default:
                    break
                }
            }
            col2state[c * 2] = np1 < np2 ? .normal : np1 == np2 ? .complete : .error
            col2state[c * 2 + 1] = nn1 < nn2 ? .normal : nn1 == nn2 ? .complete : .error
            if np1 != np2 || nn1 != nn2 {isSolved = false}
        }
        guard isSolved else {return}
        for a in game.areas {
            switch a.type {
            case .single:
                continue
            case .horizontal, .vertical:
                let os = MagnetsGame.offset[a.type == .horizontal ? 1 : 2]
                let (o1, o2) = (self[a.p], self[a.p + os])
                if o1.isEmpty() != o2.isEmpty() {
                    isSolved = false; return
                }
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[r, c]
                for os in MagnetsGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2) else {continue}
                    let o2 = self[p2]
                    if o.isPole() && o == o2 {
                        isSolved = false; return
                    }
                }
            }
        }
    }
}
