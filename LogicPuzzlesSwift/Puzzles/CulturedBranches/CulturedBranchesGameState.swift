//
//  CulturedBranchesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CulturedBranchesGameState: GridGameState<CulturedBranchesGameMove> {
    var game: CulturedBranchesGame {
        get { getGame() as! CulturedBranchesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CulturedBranchesDocument.sharedInstance }
    var objArray = [CulturedBranchesObject]()
    
    override func copy() -> CulturedBranchesGameState {
        let v = CulturedBranchesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CulturedBranchesGameState) -> CulturedBranchesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CulturedBranchesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CulturedBranchesObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> CulturedBranchesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CulturedBranchesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CulturedBranchesGameMove) -> GameOperationType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return .invalid }
        guard String(describing: o1) != String(describing: o2) else { return .invalid }
        self[p] = o2
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout CulturedBranchesGameMove) -> GameOperationType {
        // 3. CulturedBranches can't run over the numbers.
        func f(o: CulturedBranchesObject) -> CulturedBranchesObject {
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
        iOS Game: 100 Logic Games 3/Puzzle Set 3/Cultured Branches

        Summary
        Well-read trees

        Description
        1. Each Letter represents a tree. A tree has branches coming out of it,
           in any of the four directions around it.
        2. Each Letter stands for a number and no two Letters stand for the same number.
        3. The number tells you the total length of the Branches coming out of
           that Tree.
        4. In the example all 'A' means '2' and all 'B' means '4'.
        5. Every Tree having the same number must have a different number of Branches
           (1 to 4 in the possible directions around it).
        6. In the example the top Letter 'B' has 3 branches (left, right, down)
           while the bottom one has 2 (up and left).
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
                    return
                case .hint(_):
                    // 1. In CulturedBranches you must fill the board with straight horizontal and
                    // vertical lines(CulturedBranches) that stem from each number.
                    // The tile with the number doesn't count.
                    var n1 = 0, n2 = game.pos2hint[p]!
                    next: for i in 0..<4 {
                        let os = CulturedBranchesGame.offset[i]
                        var p2 = p + os
                        // 3. CulturedBranches can't overlap,
                        // CulturedBranches must be in a single straight line and can't make corners.
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
                    // 2. The number itself tells you how many tiles its CulturedBranches fill up.
                    let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
                    self[p] = .hint(state: s)
                    if s != .complete { isSolved = false }
                default:
                    break
                }
            }
        }
    }
}
