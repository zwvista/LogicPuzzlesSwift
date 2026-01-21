//
//  SlitherCornerGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SlitherCornerGameState: GridGameState<SlitherCornerGameMove> {
    var game: SlitherCornerGame {
        get { getGame() as! SlitherCornerGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SlitherCornerDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> SlitherCornerGameState {
        let v = SlitherCornerGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SlitherCornerGameState) -> SlitherCornerGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: SlitherCornerGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> GridDotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    private func isValidMove(move: inout SlitherCornerGameMove) -> Bool {
        !(move.p.row == rows - 1 && move.dir == 2 ||
            move.p.col == cols - 1 && move.dir == 1)
    }
    
    override func setObject(move: inout SlitherCornerGameMove) -> GameOperationType {
        guard isValidMove(move: &move) else { return .invalid }
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let p = move.p
        let dir = move.dir, dir2 = (dir + 2) % 4
        f(o1: &self[p][dir], o2: &self[p + SlitherCornerGame.offset[dir]][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout SlitherCornerGameMove) -> GameOperationType {
        guard isValidMove(move: &move) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            default:
                return o
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 2/SlitherCorner

        Summary
        Corners instead of sides

        Description
        1. Draw a path like a SlitherLink (non intercepting loop) with the
           following hints:
        2. The number in a cell tells you how many tiles the path turn by 90
           degrees around it.
        3. Note that around 0s that can be a line but it just don't won't turn.
    */
    private func updateIsSolved() {
        isSolved = true
        // 1. Draw a single looping path with the aid of the numbered hints.
        // 2. The number in a cell tells you how many tiles the path turn by 90
        //    degrees around it.
        for (p, n2) in game.pos2hint {
            let pDots = SlitherCornerGame.offset2.map { p + $0 }
            let counts = pDots.map { p2 in (0..<4).count { self[p2][$0] == .line } }
            if counts.allSatisfy({ $0 == 0 }) || !counts.allSatisfy({ $0 == 2 || $0 == 0 }) {
                pos2state[p] = .normal
            } else {
                let dirs2D = pDots.map { p2 in (0..<4).filter { self[p2][$0] == .line } }.filter { $0.count == 2 }
                let n1 = dirs2D.count { $0[1] - $0[0] != 2 }
                pos2state[p] = n1 == n2 ? .complete : .error
            }
            if pos2state[p] != .complete { isSolved = false }
        }
        guard isSolved else {return}
        var pos2Dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] == .line }
                if dirs.count == 2 {
                    // 1. Draw a single looping path
                    pos2Dirs[p] = dirs
                } else if !dirs.isEmpty {
                    // 1. The path cannot have branches or cross itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        guard let p = pos2Dirs.keys.first else { isSolved = false; return }
        var p2 = p
        var n = -1
        while true {
            guard let dirs = pos2Dirs[p2] else { isSolved = false; return }
            pos2Dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += SlitherCornerGame.offset[n]
            guard p2 != p else {return}
        }
    }
}
