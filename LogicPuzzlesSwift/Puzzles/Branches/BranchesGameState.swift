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
    var pos2state = [Position: HintState]()

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
            self[p] = .hint
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
    
    override func setObject(move: inout BranchesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != .hint, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout BranchesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != .hint else { return .invalid }
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
        move.obj = f(o: self[p])
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
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .empty:
                    // 3. There can't be blank tiles.
                    isSolved = false
                case .hint:
                    // 1. In Branches you must fill the board with straight horizontal and
                    // vertical lines(Branches) that stem from each number.
                    // The tile with the number doesn't count.
                    var n1 = 0, n2 = game.pos2hint[p]!
                    for i in 0..<4 {
                        let os = BranchesGame.offset[i]
                        var p2 = p + os
                        // 3. Branches can't overlap,
                        // Branches must be in a single straight line and can't make corners.
                        next: while isValid(p: p2) {
                            switch self[p2] {
                            case .up:
                                if i == 0 { n1 += 1 }
                                break next
                            case .right:
                                if i == 1 { n1 += 1 }
                                break next
                            case .down:
                                if i == 2 { n1 += 1 }
                                break next
                            case .left:
                                if i == 3 { n1 += 1 }
                                break next
                            case .horizontal:
                                if i % 2 == 1 { n1 += 1 } else { break next }
                            case .vertical:
                                if i % 2 == 0 { n1 += 1 } else { break next }
                            default:
                                break next
                            }
                            p2 += os
                        }
                    }
                    // 2. The number itself tells you how many tiles its Branches fill up.
                    let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
                    pos2state[p] = s
                    if s != .complete { isSolved = false }
                default:
                    break
                }
            }
        }
    }
}
