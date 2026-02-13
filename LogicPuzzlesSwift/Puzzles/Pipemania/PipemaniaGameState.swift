//
//  PipemaniaGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PipemaniaGameState: GridGameState<PipemaniaGameMove> {
    var game: PipemaniaGame {
        get { getGame() as! PipemaniaGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PipemaniaDocument.sharedInstance }
    var objArray = [PipemaniaObject]()
    
    override func copy() -> PipemaniaGameState {
        let v = PipemaniaGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PipemaniaGameState) -> PipemaniaGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PipemaniaGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> PipemaniaObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PipemaniaObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout PipemaniaGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), case .empty = game[p], String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout PipemaniaGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: .upright
        case .upright: .downright
        case .downright: .leftdown
        case .leftdown: .leftup
        case .leftup: .horizontal
        case .horizontal: .vertical
        case .vertical: .cross
        case .cross: .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 5/Pipemania

        Summary
        Back to the 80s

        Description
        1. The former contractor for your present client left the work unfinished.
           In order not to waste what has bee done, you should complete the pipe
           loop, using the pieces available.
        2. Complete the board using all the tiles and form a single closed loop.
        3. The loop can cross itself.
        4. please note “a single closed loop" means that assuming the flow is straight
           even when the pipe crosses itself, i.e. following the pipe in straight lines
           (not turning at crossings).
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        // 1. The former contractor for your present client left the work unfinished.
        //    In order not to waste what has bee done, you should complete the pipe
        //    loop, using the pieces available.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                if o == .empty { isSolved = false }
                pos2dirs[p] = switch o {
                case .upright: [0, 1]
                case .downright: [1, 2]
                case .leftdown: [2, 3]
                case .leftup: [0, 3]
                case .horizontal: [1, 3]
                case .vertical: [0, 2]
                case .cross: [0, 1, 2, 3]
                default: []
                }
            }
        }
        guard isSolved else {return}
        // 2. Complete the board using all the tiles and form a single closed loop.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = pos2dirs[p]!
                guard (dirs.allSatisfy {
                    let p2 = p + PipemaniaGame.offset[$0]
                    guard let dirs2 = pos2dirs[p2] else { return false }
                    return dirs2.contains(($0 + 2) % 4)
                }) else { isSolved = false; return }
            }
        }
        // 3. The loop can cross itself.
        // 4. please note “a single closed loop" means that assuming the flow is straight
        //    even when the pipe crosses itself, i.e. following the pipe in straight lines
        //    (not turning at crossings).
        // Check the loop
        let p = pos2dirs.keys.first!
        var p2 = p, n = -1
        while true {
            guard var dirs = pos2dirs[p2] else { isSolved = false; return }
            if dirs.count == 2 {
                pos2dirs.removeValue(forKey: p2)
                n = dirs.first { ($0 + 2) % 4 != n }!
            } else {
                dirs.removeAll(n)
                dirs.removeAll((n + 2) % 4)
                pos2dirs[p2] = dirs
            }
            p2 += PipemaniaGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
