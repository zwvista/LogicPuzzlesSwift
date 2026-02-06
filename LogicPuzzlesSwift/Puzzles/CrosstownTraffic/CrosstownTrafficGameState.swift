//
//  CrosstownTrafficGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CrosstownTrafficGameState: GridGameState<CrosstownTrafficGameMove> {
    var game: CrosstownTrafficGame {
        get { getGame() as! CrosstownTrafficGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CrosstownTrafficDocument.sharedInstance }
    var objArray = [CrosstownTrafficObject]()
    var pos2state = [Position: HintState]()

    override func copy() -> CrosstownTrafficGameState {
        let v = CrosstownTrafficGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CrosstownTrafficGameState) -> CrosstownTrafficGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CrosstownTrafficGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CrosstownTrafficObject>(repeating: .empty, count: rows * cols)
        for (p, _) in game.pos2hint { self[p] = .hint }
        updateIsSolved()
    }
    
    subscript(p: Position) -> CrosstownTrafficObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CrosstownTrafficObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CrosstownTrafficGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout CrosstownTrafficGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: CrosstownTrafficObject) -> CrosstownTrafficObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .upright
            case .upright:
                return .downright
            case .downright:
                return .leftdown
            case .leftdown:
                return .leftup
            case .leftup:
                return .horizontal
            case .horizontal:
                return .vertical
            case .vertical:
                return .cross
            case .cross:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .upright : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 3/Crosstown Traffic

        Summary
        looks like pipes made of asphalt

        Description
        1. Draw a circuit (looping road)
        2. The road may cross itself, but otherwise does not touch or retrace itself.
        3. The numbers along the edge indicate the stretch of the nearest section
           of road from that point, in corresponding row or column.
        4. For example if the first stretch of road is curve, straight and curve
           the number of that hint is 3.
        5. Another example: if the first stretch of road is curve and curve,
           the number of that hint is 2.
        6. Not all tiles should be used. In some levels some part of the board
           can remain unused.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                switch self[p] {
                case .upright:
                    pos2dirs[p] = [0, 1]
                case .downright:
                    pos2dirs[p] = [1, 2]
                case .leftdown:
                    pos2dirs[p] = [2, 3]
                case .leftup:
                    pos2dirs[p] = [0, 3]
                case .horizontal:
                    pos2dirs[p] = [1, 3]
                case .vertical:
                    pos2dirs[p] = [0, 2]
                case .cross:
                    pos2dirs[p] = [0, 1, 2, 3]
                default:
                    break
                }
            }
        }
        // 3. The numbers along the edge indicate the stretch of the nearest section
        //    of road from that point, in corresponding row or column.
        for r in 1..<rows - 1 {
            var n1 = 0
            var pHint = Position(r, 0)
            var n2 = game.pos2hint[pHint]!
            for c in 1..<cols - 1 {
                let dirs = pos2dirs[Position(r, c)] ?? []
                let (b1, b2) = (dirs.contains(1), dirs.contains(3))
                if b1 && !b2 && n1 == 0 || b1 && b2 && n1 > 0 {
                    n1 += 1
                } else if !b1 && b2 && n1 > 0 {
                    n1 += 1
                    break
                } else if n1 > 0 {
                    break
                }
            }
            var s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[pHint] = s
            if s != .complete { isSolved = false }
            n1 = 0
            pHint = Position(r, cols - 1)
            n2 = game.pos2hint[pHint]!
            for c in stride(from: cols - 2, through: 1, by: -1) {
                let dirs = pos2dirs[Position(r, c)] ?? []
                let (b1, b2) = (dirs.contains(3), dirs.contains(1))
                if b1 && !b2 && n1 == 0 || b1 && b2 && n1 > 0 {
                    n1 += 1
                } else if !b1 && b2 && n1 > 0 {
                    n1 += 1
                    break
                } else if n1 > 0 {
                    break
                }
            }
            s = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[pHint] = s
            if s != .complete { isSolved = false }
        }
        for c in 1..<cols - 1 {
            var n1 = 0
            var pHint = Position(0, c)
            var n2 = game.pos2hint[pHint]!
            for r in 1..<rows - 1 {
                let dirs = pos2dirs[Position(r, c)] ?? []
                let (b1, b2) = (dirs.contains(2), dirs.contains(0))
                if b1 && !b2 && n1 == 0 || b1 && b2 && n1 > 0 {
                    n1 += 1
                } else if !b1 && b2 && n1 > 0 {
                    n1 += 1
                    break
                } else if n1 > 0 {
                    break
                }
            }
            var s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[pHint] = s
            if s != .complete { isSolved = false }
            n1 = 0
            pHint = Position(rows - 1, c)
            n2 = game.pos2hint[pHint]!
            for r in stride(from: rows - 2, through: 1, by: -1) {
                let dirs = pos2dirs[Position(r, c)] ?? []
                let (b1, b2) = (dirs.contains(0), dirs.contains(2))
                if b1 && !b2 && n1 == 0 || b1 && b2 && n1 > 0 {
                    n1 += 1
                } else if !b1 && b2 && n1 > 0 {
                    n1 += 1
                    break
                } else if n1 > 0 {
                    break
                }
            }
            s = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[pHint] = s
            if s != .complete { isSolved = false }
        }
        guard isSolved else {return}
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
            }
            p2 += CrosstownTrafficGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
