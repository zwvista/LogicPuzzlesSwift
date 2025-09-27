//
//  BranchesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BranchesGameState: GridGameState<BranchesGameMove> {
    var game: BranchesGame {
        get { getGame() as! BranchesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { BranchesDocument.sharedInstance }
    var objArray = [BranchesObject]()
    
    override func copy() -> BranchesGameState {
        let v = BranchesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BranchesGameState) -> BranchesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: BranchesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BranchesObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> BranchesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> BranchesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout BranchesGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return false }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout BranchesGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        // 3. Branches can't run over the numbers.
        func f(o: BranchesObject) -> BranchesObject {
            switch o {
            case .empty:
                return .up
            case .up:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .horizontal
            case .horizontal:
                return .vertical
            case .vertical:
                return .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 2/Branches

        Summary
        Fill the board with Branches departing from the numbers

        Description
        1. In Branches you must fill the board with straight horizontal and
           vertical lines(Branches) that stem from each number.
        2. The number itself tells you how many tiles its Branches fill up.
           The tile with the number doesn't count.
        3. There can't be blank tiles and Branches can't overlap, nor run over
           the numbers. Moreover Branches must be in a single straight line
           and can't make corners.
    */
    private func updateIsSolved() {
        isSolved = true
        // 1. In Branches you must fill the board with straight horizontal and
        // vertical lines(Branches) that stem from each number.
        // 2. The number itself tells you how many tiles its Branches fill up.
        // The tile with the number doesn't count.
        // 3. Branches can't overlap,
        // Branches must be in a single straight line and can't make corners.
        for (p, n2) in game.pos2hint {
            func f() -> HintState {
                var n1 = 0
                next: for i in 0..<4 {
                    let os = BranchesGame.offset[i]
                    var p2 = p + os
                    while isValid(p: p2) {
                        switch self[p2] {
                        case .up:
                            if i == 0 { n1 += 1 }
                            continue next
                        case .right:
                            if i == 1 { n1 += 1 }
                            continue next
                        case .down:
                            if i == 2 { n1 += 1 }
                            continue next
                        case .left:
                            if i == 3 { n1 += 1 }
                            continue next
                        case .horizontal:
                            if i % 2 == 1 { n1 += 1 } else { continue next }
                        case .vertical:
                            if i % 2 == 0 { n1 += 1 } else { continue next }
                        default:
                            break
                        }
                        p2 += os
                    }
                }
                return n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            }
            let s = f()
            self[p] = .hint(state: s)
            if s != .complete { isSolved = false }
        }
        // 3. There can't be blank tiles.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .empty:
                    isSolved = false
                    return
                default:
                    break
                }
            }
        }
    }
}
