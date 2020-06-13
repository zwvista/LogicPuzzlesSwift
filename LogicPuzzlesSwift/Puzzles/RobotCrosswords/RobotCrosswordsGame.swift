//
//  RobotCrosswordsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class RobotCrosswordsGame: GridGame<RobotCrosswordsGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

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
                if isHorz {horzAreaCount += 1}
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
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> Int {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Int {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }

    func switchObject(move: inout RobotCrosswordsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout RobotCrosswordsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
