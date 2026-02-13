//
//  MirrorsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MirrorsGameState: GridGameState<MirrorsGameMove> {
    var game: MirrorsGame {
        get { getGame() as! MirrorsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MirrorsDocument.sharedInstance }
    var objArray = [MirrorsObject]()
    var pos2dirsAll = [Position: [Int]]()

    override func copy() -> MirrorsGameState {
        let v = MirrorsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MirrorsGameState) -> MirrorsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MirrorsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> MirrorsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MirrorsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MirrorsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout MirrorsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: .upRight
        case .upRight: .downRight
        case .downRight: .downLeft
        case .downLeft: .upLeft
        case .upLeft: .horizontal
        case .horizontal: .vertical
        case .vertical: .empty
        default: o
        }
        return setObject(move: &move)
    }

    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 10/Mirrors

        Summary
        Zip, swish, zoom! Lasers on mirrors!

        Description
        1. The goal is to draw a single, continuous, non-crossing path that fills
           the entire board.
        2. Some tiles are already given and can contain Mirrors, which force the
           path to make a turn. Other tiles already contain a fixed piece of straight
           path.
        3. Your task is to fill the remaining board tiles with straight or 90 degree
           path lines, in the end connecting a single, continuous line.
        4. Please note you can make 90 degree turn even there are no mirrors.

        Variant
        5. In the Maze variant, the path isn't closed. You have two spots on the
           board which represent the start and end of the path.
    */
    private func updateIsSolved() {
        isSolved = true
        // 2. Some tiles are already given and can contain Mirrors, which force the
        //    path to make a turn. Other tiles already contain a fixed piece of straight
        //    path.
        // 3. Your task is to fill the remaining board tiles with straight or 90 degree
        //    path lines, in the end connecting a single, continuous line.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                if o == .empty { isSolved = false }
                pos2dirsAll[p] = switch o {
                case .upRight: [0, 1]
                case .downRight: [1, 2]
                case .downLeft: [2, 3]
                case .upLeft: [0, 3]
                case .horizontal: [1, 3]
                case .vertical: [0, 2]
                default: []
                }
            }
        }
        guard isSolved else {return}
        var pos2dirs = pos2dirsAll
        // 1. The goal is to draw a single, continuous, non-crossing path that fills
        //    the entire board.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = pos2dirs[p]!
                guard (dirs.allSatisfy {
                    let p2 = p + MirrorsGame.offset[$0]
                    guard let dirs2 = pos2dirs[p2] else { return false }
                    return dirs2.contains(($0 + 2) % 4)
                }) else { isSolved = false; return }
            }
        }
        // Check the loop
        let p = pos2dirs.keys.first!
        var p2 = p, n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += MirrorsGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
