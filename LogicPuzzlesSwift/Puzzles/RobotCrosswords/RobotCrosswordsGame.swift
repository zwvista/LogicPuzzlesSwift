//
//  RobotCrosswordsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class RobotCrosswordsGame: GridGame<RobotCrosswordsGameState> {
    static let offset = Position.Directions4

    var areas = [[Position]]()
    var objArray = [Int]()
    var horzAreaCount = 0

    init(layout: [String], delegate: RobotCrosswordsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Int>(repeating: 0, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = ch == "." ? -1 : ch == " " ? 0 : ch.toInt!
            }
        }
        var area = [Position]()
        func f(isHorz: Bool) {
            guard !area.isEmpty else {return}
            if area.count > 1 {
                areas.append(area)
                if isHorz { horzAreaCount += 1 }
            }
            area.removeAll()
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if(self[p] == -1) {
                    f(isHorz: true)
                } else {
                    area.append(p)
                }
            }
            f(isHorz: true)
        }
        for c in 0..<cols {
            for r in 0..<rows {
                let p = Position(r, c)
                if(self[p] == -1) {
                    f(isHorz: false)
                } else {
                    area.append(p)
                }
            }
            f(isHorz: false)
        }

        let state = RobotCrosswordsGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
