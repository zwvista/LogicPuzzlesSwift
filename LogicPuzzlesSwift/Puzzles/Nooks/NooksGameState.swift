//
//  NooksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NooksGameState: GridGameState<NooksGameMove> {
    var game: NooksGame {
        get { getGame() as! NooksGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { NooksDocument.sharedInstance }
    var objArray = [NooksObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> NooksGameState {
        let v = NooksGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NooksGameState) -> NooksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: NooksGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<NooksObject>(repeating: NooksObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> NooksObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> NooksObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout NooksGameMove) -> GameOperationType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        guard String(describing: o1) != String(describing: o2) else { return .invalid }
        self[p] = o2
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout NooksGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .bread()
        case .bread: .ham()
        case .ham: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .bread() : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 17/Nooks

        Summary
        ...in a forest

        Description
        1. Fill some tiles with hedges, so that each number (where someone is playing hide and seek)
           finds itself in the nook.
        2. a Nook is a dead end, one tile wide, with a number in it.
        3. a Nook contains a number that shows you how many tiles can be seen in a straight line from
           there, including the tile itself.
        4. The resulting maze should be a single one-tile path connected horizontally or vertically
           where there are no 2x2 areas of the same type (hedge or path).
        5. No area in the maze can have the characteristics of a Nook without a number in it.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                switch self[r, c] {
                case .forbidden:
                    self[r, c] = .empty
                case .bread:
                    self[r, c] = .bread()
                case .ham:
                    self[r, c] = .ham()
                default:
                    break
                }
            }
        }
        for r in 0..<rows {
            var breads = [Position](), hams = [Position]()
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .bread:
                    breads.append(p)
                case .ham:
                    hams.append(p)
                default:
                    break
                }
            }
            if breads.count > 2 {
                for p in breads { self[p] = .bread(state: .error) }
            }
            if hams.count > rows - 3 {
                for p in hams { self[p] = .ham(state: .error) }
            }
            if breads.count != 2 {
                isSolved = false
                row2state[r] = .normal
            } else {
                let n2 = game.row2hint[r]
                guard n2 >= 0 else {continue}
                // 1. Each row and column contains two Slices of Bread and N-3 Pieces of Pieces of Ham
                //    (N being the board size). i.e. a board side 6, will have 3 Pieces of Ham.
                let n1 = hams.count { $0.col > breads[0].col && $0.col < breads[1].col }
                let s: HintState = n1 == n2 ? .complete : .error
                row2state[r] = s
                guard allowedObjectsOnly && hams.count == rows - 3 else {continue}
                (0..<cols).filter { self[r, $0].toString() == "empty" }.forEach {
                    self[r, $0] = .forbidden
                }
            }
        }
        for c in 0..<cols {
            var breads = [Position](), hams = [Position]()
            for r in 0..<rows {
                let p = Position(r, c)
                switch self[p] {
                case .bread:
                    breads.append(p)
                case .ham:
                    hams.append(p)
                default:
                    break
                }
            }
            if breads.count > 2 {
                for p in breads { self[p] = .bread(state: .error) }
            }
            if hams.count > rows - 3 {
                for p in hams { self[p] = .ham(state: .error) }
            }
            if breads.count != 2 {
                isSolved = false
                col2state[c] = .normal
            } else {
                let n2 = game.col2hint[c]
                guard n2 >= 0 else {continue}
                // 1. Each row and column contains two Slices of Bread and N-3 Pieces of Pieces of Ham
                //    (N being the board size). i.e. a board side 6, will have 3 Pieces of Ham.
                let n1 = hams.count { $0.row > breads[0].row && $0.row < breads[1].row }
                let s: HintState = n1 == n2 ? .complete : .error
                col2state[c] = s
                guard allowedObjectsOnly && hams.count == rows - 3 else {continue}
                (0..<rows).filter { self[$0, c].toString() == "empty" }.forEach {
                    self[$0, c] = .forbidden
                }
            }
        }
    }
}
