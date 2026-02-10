//
//  CultureTripGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CultureTripGameState: GridGameState<CultureTripGameMove> {
    var game: CultureTripGame {
        get { getGame() as! CultureTripGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CultureTripDocument.sharedInstance }
    var objArray = [CultureTripObject]()
    
    override func copy() -> CultureTripGameState {
        let v = CultureTripGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CultureTripGameState) -> CultureTripGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CultureTripGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CultureTripObject>(repeating: CultureTripObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> CultureTripObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CultureTripObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CultureTripGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + CultureTripGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 1/Culture Trip

        Summary
        Or how to make a culture trip complicated

        Description
        1. The board represents a City of Art and Culture, divided in neighborhoods.
        2. During a Culture Trip, in order to make everybody happy, you devise a
           convoluted method to visit a city:
        3. All neighborhoods must be visited exactly and only once.
        4. You have to set foot in a neighborhood only once and can't come back after
           you leave it.
        5. In a neighborhood, you either visit All Museums or All Monuments.
        6. If you visit Monuments, you can't pass over Museums and vice-versa.
        7. You have to alternate between neighborhoods where you visit Museums and
           those where you visit Monuments.
        8. After visiting Museums, you should visit Monuments, then Museums again, etc.
        9. The Trip must form a closed loop, in the end returning to the starting
           neighborhood.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                    let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    // 9. The Trip must form a closed loop, in the end returning to the starting
                    //    neighborhood.
                    pos2dirs[p] = dirs
                } else if !dirs.isEmpty {
                    // The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        guard let p = pos2dirs.keys.first(where: { game[$0] != " " }) else { isSolved = false; return }
        var p2 = p, n = -1
        var lastArea = -1
        var area2count = [Int: Int]()
        var area2chars = [Int: [Character]]()
        var ch: Character = " "
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            let area = game.pos2area[p2]!
            let ch2 = game[p2]
            if ch2 != " " {
                area2chars[area, default: []].append(ch2)
                // 7. You have to alternate between neighborhoods where you visit Museums and
                //    those where you visit Monuments.
                // 8. After visiting Museums, you should visit Monuments, then Museums again, etc.
                if area != lastArea && ch2 == ch { isSolved = false; return }
                ch = ch2
            }
            if area != lastArea {
                area2count[area] = (area2count[area] ?? 0) + 1
                lastArea = area
            }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += CultureTripGame.offset[n]
            guard p2 != p else {
                if area == game.pos2area[p]! {
                    area2count[area] = area2count[area]! - 1
                }
                break
            }
        }
        // 3. All neighborhoods must be visited exactly and only once.
        // 4. You have to set foot in a neighborhood only once and can't come back after
        //    you leave it.
        // 5. In a neighborhood, you either visit All Museums or All Monuments.
        // 6. If you visit Monuments, you can't pass over Museums and vice-versa.
        if !(area2count.count == game.areas.count && area2count.testAll { $1 == 1 } &&
             area2chars.count == game.areas.count && area2chars.testAll { (area, chars) in
            let s = Set(chars)
            if s.count != 1 { return false }
            let ch = s.first!
            return chars.count == game.areas[area].count { game[$0] == ch }
        }) { isSolved = false }
    }
}
