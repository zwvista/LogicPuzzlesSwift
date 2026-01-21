//
//  SlitherLinkGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SlitherLinkGameState: GridGameState<SlitherLinkGameMove> {
    var game: SlitherLinkGame {
        get { getGame() as! SlitherLinkGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SlitherLinkDocument.sharedInstance }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> SlitherLinkGameState {
        let v = SlitherLinkGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SlitherLinkGameState) -> SlitherLinkGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: SlitherLinkGame, isCopy: Bool = false) {
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
    
    private func isValidMove(move: inout SlitherLinkGameMove) -> Bool {
        !(move.p.row == rows - 1 && move.dir == 2 ||
            move.p.col == cols - 1 && move.dir == 1)
    }
    
    override func setObject(move: inout SlitherLinkGameMove) -> GameOperationType {
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
        f(o1: &self[p][dir], o2: &self[p + SlitherLinkGame.offset[dir]][dir2])
        if changed { updateIsSolved() }
        return changed ? .moveComplete : .invalid
    }
    
    override func switchObject(move: inout SlitherLinkGameMove) -> GameOperationType {
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
        iOS Game: Logic Games/Puzzle Set 3/SlitherLink

        Summary
        Draw a loop a-la-minesweeper!

        Description
        1. Draw a single looping path with the aid of the numbered hints. The path
           cannot have branches or cross itself.
        2. Each number in a tile tells you on how many of its four sides are touched
           by the path.
        3. For example:
        4. A 0 tells you that the path doesn't touch that square at all.
        5. A 1 tells you that the path touches that square ONLY one-side.
        6. A 3 tells you that the path does a U-turn around that square.
        7. There can't be tiles marked with 4 because that would form a single
           closed loop in it.
        8. Empty tiles can have any number of sides touched by that path.
    */
    private func updateIsSolved() {
        isSolved = true
        // 1. Draw a single looping path with the aid of the numbered hints.
        // 2. Each number in a tile tells you on how many of its four sides are touched
        //    by the path.
        for (p, n2) in game.pos2hint {
            let n1 = (0..<4).count { i in self[p + SlitherLinkGame.offset2[i]][SlitherLinkGame.dirs[i]] == .line }
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
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
            p2 += SlitherLinkGame.offset[n]
            guard p2 != p else {return}
        }
    }
}
