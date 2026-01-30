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
    var pos2state = [Position: HintState]()

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
            self[p] = .hint
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
        guard isValid(p: p), self[p] != .hint, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout CulturedBranchesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != .hint else { return .invalid }
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
        move.obj = f(o: self[p])
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
        var ch2rng = [Character: [Position]]()
        var ch2lens = [Character: Set<Int>]()
        var ch2nums = [Character: Set<Int>]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .empty:
                    // 3. There can't be blank tiles.
                    isSolved = false
                case .hint:
                    // 1. In CulturedBranches you must fill the board with straight horizontal and
                    // vertical lines(CulturedBranches) that stem from each number.
                    // The tile with the number doesn't count.
                    let ch = game.pos2hint[p]!
                    var len = 0, num = 0
                    for i in 0..<4 {
                        let os = CulturedBranchesGame.offset[i]
                        var p2 = p + os
                        var n = 0
                        // 3. CulturedBranches can't overlap,
                        // CulturedBranches must be in a single straight line and can't make corners.
                        next: while isValid(p: p2) {
                            switch self[p2] {
                            case .up:
                                if i == 0 { n += 1 }
                                break next
                            case .right:
                                if i == 1 { n += 1 }
                                break next
                            case .down:
                                if i == 2 { n += 1 }
                                break next
                            case .left:
                                if i == 3 { n += 1 }
                                break next
                            case .horizontal:
                                if i % 2 == 1 { n += 1 } else { break next }
                            case .vertical:
                                if i % 2 == 0 { n += 1 } else { break next }
                            default:
                                break next
                            }
                            p2 += os
                        }
                        if n > 0 {
                            len += n
                            num += 1
                        }
                    }
                    ch2rng[ch, default: []].append(p)
                    ch2lens[ch, default: []].insert(len)
                    ch2nums[ch, default: []].insert(num)
                default:
                    break
                }
            }
        }
        for (ch, rng) in ch2rng {
            let lens = ch2lens[ch]!
            let nums = ch2nums[ch]!
            let s: HintState = lens.allSatisfy({ $0 == 0 }) ? .normal : lens.count == 1 && nums.count == rng.count ? .complete : .error
            if s != .complete { isSolved = false }
            for p in rng { pos2state[p] = s }
        }
    }
}
