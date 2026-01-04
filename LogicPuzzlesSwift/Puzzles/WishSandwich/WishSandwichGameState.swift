//
//  WishSandwichGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class WishSandwichGameState: GridGameState<WishSandwichGameMove> {
    var game: WishSandwichGame {
        get { getGame() as! WishSandwichGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { WishSandwichDocument.sharedInstance }
    var objArray = [WishSandwichObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> WishSandwichGameState {
        let v = WishSandwichGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: WishSandwichGameState) -> WishSandwichGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: WishSandwichGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<WishSandwichObject>(repeating: WishSandwichObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> WishSandwichObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> WishSandwichObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout WishSandwichGameMove) -> GameOperationType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        guard String(describing: o1) != String(describing: o2) else { return .invalid }
        self[p] = o2
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout WishSandwichGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: WishSandwichObject) -> WishSandwichObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .post(state: .normal)
            case .post:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .post(state: .normal) : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 3/Wish Sandwich

        Summary
        ...ever heard of it ?

        Description
        1. Each row and column contains two Slices of Bread and a number of Pieces of
           Ham, which is given in the top right corner.
        2. A number at the edge indicates how many Pieces of Ham you managed to put
           between the two Slices of Bread in that row or column.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .post:
                    self[p] = .post(state: .normal)
                default:
                    break
                }
            }
        }
        for r in 0..<rows {
            var posts = [Position]()
            for c in 0..<cols {
                let p = Position(r, c)
                if case .post = self[p] { posts.append(p) }
            }
            let n1 = posts.count, n2 = game.row2hint[r] + 1
            // 2. There are two Posts in each Row.
            // 3. The numbers on the side tell you the length of the cables between
            // the two Posts (in that Row).
            let s: HintState = n1 < 2 ? .normal : n1 == 2 && n2 == posts[1].col - posts[0].col ? .complete : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
            if s == .error {
                for p in posts {
                    self[p] = .post(state: .error)
                }
            }
            guard allowedObjectsOnly && n1 > 0 else {continue}
            for c in 0..<cols {
                if case .empty = self[r, c], n1 > 1 || n1 == 1 && n2 != abs(posts[0].col - c) {
                    self[r, c] = .forbidden
                }
            }
        }
        for c in 0..<cols {
            var posts = [Position]()
            for r in 0..<rows {
                let p = Position(r, c)
                if case .post = self[p] { posts.append(p) }
            }
            let n1 = posts.count, n2 = game.col2hint[c] + 1
            // 2. There are two Posts in each Column.
            // 3. The numbers on the side tell you the length of the cables between
            // the two Posts (in that Column).
            let s: HintState = n1 < 2 ? .normal : n1 == 2 && n2 == posts[1].row - posts[0].row ? .complete : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
            if s == .error {
                for p in posts {
                    self[p] = .post(state: .error)
                }
            }
            guard allowedObjectsOnly && n1 > 0 else {continue}
            for r in 0..<rows {
                if case .empty = self[r, c], n1 > 1 || n1 == 1 && n2 != abs(posts[0].row - r) {
                    self[r, c] = .forbidden
                }
            }
        }
    }
}
