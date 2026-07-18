//
//  MirrorsExtendedGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import OrderedCollections

class MirrorsExtendedGameState: GridGameState<MirrorsExtendedGameMove> {
    var game: MirrorsExtendedGame {
        get { getGame() as! MirrorsExtendedGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MirrorsExtendedDocument.sharedInstance }
    var objArray = [MirrorsExtendedObject]()
    var letter2state = [Character: HintState]()

    override func copy() -> MirrorsExtendedGameState {
        let v = MirrorsExtendedGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MirrorsExtendedGameState) -> MirrorsExtendedGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MirrorsExtendedGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> MirrorsExtendedObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MirrorsExtendedObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MirrorsExtendedGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout MirrorsExtendedGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .backward
        case .backward: .forward
        case .forward: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .backward : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 4/Mirrors, extended

        Summary
        with lasers, of course

        Description
        1. On the border there are some lasers, marked with the letter and number.
        2. The letter tells you where that laser beam will start and end (it is paired with the same
           letter somewhere else).
        3. The number tells you how many mirrors the laser beam will bounce off before reaching the
           other letter.
        4. Each area contains one mirror.
        5. Each mirror reflects at least one laser beam.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        var dot2dot = [MirrorsExtendedLaserDot: MirrorsExtendedLaserDot]()
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                let o = self[p]
                switch o {
                case .forbidden:
                    self[p] = .empty
                case .forward, .backward:
                    let md = MirrorsExtendedGame.mirrorDirs[o == .forward ? 0 : 1]
                    for i in 0..<4 {
                        let d = md[i]
                        dot2dot[MirrorsExtendedLaserDot(p: p, dir: i)] = MirrorsExtendedLaserDot(p: p + MirrorsExtendedGame.offset[d], dir: d)
                    }
                default:
                    break
                }
            }
        }
        for area in game.areas {
            let rng = area.filter { self[$0].isMirror }
            if rng.count != 1 { isSolved = false }
            if !rng.isEmpty && allowedObjectsOnly {
                for p in area where !self[p].isMirror {
                    self[p] = .forbidden
                }
            }
        }
        for (ch, o) in game.letter2laser {
            var dt = o.dots[0]
            let p2 = o.dots[1].p
            var n1 = 0
            let n2 = o.number
            while true {
                if let dt2 = dot2dot[dt] {
                    dt = dt2
                    n1 += 1
                } else {
                    dt = MirrorsExtendedLaserDot(p: dt.p + MirrorsExtendedGame.offset[dt.dir], dir: dt.dir)
                }
                let p = dt.p
                let o2 = self[p]
                if o2 == .boundary {
                    letter2state[ch] = .normal
                    isSolved = false
                    break
                } else if o2 == .hint {
                    let s: HintState = p == p2 && n1 == n2 ? .complete : .error
                    letter2state[ch] = s
                    if s != .complete { isSolved = false }
                    break
                }
            }
        }
    }
}
