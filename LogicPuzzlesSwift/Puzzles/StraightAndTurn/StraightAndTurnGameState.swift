//
//  StraightAndTurnGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class StraightAndTurnGameState: GridGameState<StraightAndTurnGameMove> {
    var game: StraightAndTurnGame {
        get { getGame() as! StraightAndTurnGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { StraightAndTurnDocument.sharedInstance }
    var objArray = [StraightAndTurnObject]()
    
    override func copy() -> StraightAndTurnGameState {
        let v = StraightAndTurnGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: StraightAndTurnGameState) -> StraightAndTurnGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: StraightAndTurnGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<StraightAndTurnObject>(repeating: StraightAndTurnObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> StraightAndTurnObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> StraightAndTurnObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout StraightAndTurnGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + StraightAndTurnGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/Straight and Turn

        Summary
        Straight and Turn

        Description
        1. Draw a path that crosses all gems and follows this rule:
        2. Crossing two adjacent gems:
        3. The line cannot cross two adjacent gems if they are of different color.
        4. The line is free to either go straight or turn when crossing two
           adjacent gems of the same color.
        5. Crossing a gem that is not adjacent to the last crossed:
        6. The line should go straight in the space between two gems of the same
           colour.
        7. The line should make a single 90 degree turn in the space between
           two gems of different colour.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        var pos2Dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let ch = game[p]
                var dirs = [Int]()
                for i in 0..<4 {
                    if o[i] { dirs.append(i) }
                }
                switch dirs.count {
                case 0:
                    // 1. The goal is to draw a single Loop(Necklace) through every circle(Pearl)
                    guard ch == " " else { isSolved = false; return }
                case 2:
                    pos2node[p] = g.addNode(p.description)
                    pos2Dirs[p] = dirs
                    switch ch {
                    case "B":
                        // 4. Lines passing through Black Pearls must do a 90 degree turn in them.
                        guard dirs[1] - dirs[0] != 2 else { isSolved = false; return }
                    case "W":
                        // 3. Lines passing through White Pearls must go straight through them.
                        guard dirs[1] - dirs[0] == 2 else { isSolved = false; return }
                    default:
                        break
                    }
                default:
                    // 1. The goal is to draw a single Loop(Necklace)
                    // that never branches-off or crosses itself.
                    isSolved = false; return
                }
            }
        }
        for (p, node) in pos2node {
            let dirs = pos2Dirs[p]!
            let ch = game[p]
            var bW = ch != "W"
            for i in dirs {
                let p2 = p + StraightAndTurnGame.offset[i]
                guard let node2 = pos2node[p2], let dirs2 = pos2Dirs[p2] else { isSolved = false; return }
                switch ch {
                case "B":
                    // 4. Lines passing through Black Pearls must go straight
                    // in the next tile in both directions.
                    guard (i == 0 || i == 2) && dirs2[0] == 0 && dirs2[1] == 2 || (i == 1 || i == 3) && dirs2[0] == 1 && dirs2[1] == 3 else { isSolved = false; return }
                case "W":
                    // 3. At least at one side of the White Pearl(or both),
                    // Lines passing through White Pearls must do a 90 degree turn.
                    let n1 = (i + 1) % 4, n2 = (i + 3) % 4
                    if dirs2[0] == n1 || dirs2[0] == n2 || dirs2[1] == n1 || dirs2[1] == n2 { bW = true }
                default:
                    break
                }
                g.addEdge(node, neighbor: node2)
            }
            guard bW else { isSolved = false; return }
        }
        // 1. The goal is to draw a single Loop(Necklace).
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
