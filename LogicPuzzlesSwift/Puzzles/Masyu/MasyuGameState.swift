//
//  MasyuGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MasyuGameState: GridGameState<MasyuGameMove> {
    var game: MasyuGame {
        get { getGame() as! MasyuGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { MasyuDocument.sharedInstance }
    var objArray = [MasyuObject]()
    
    override func copy() -> MasyuGameState {
        let v = MasyuGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MasyuGameState) -> MasyuGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: MasyuGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MasyuObject>(repeating: MasyuObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MasyuObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MasyuObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout MasyuGameMove) -> GameChangeType {
        let p = move.p, dir = move.dir
        let p2 = p + MasyuGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .none }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .level
    }
    
    
    /*
        iOS Game: Logic Games/Puzzle Set 3/Masyu

        Summary
        Draw a Necklace that goes through every Pearl

        Description
        1. The goal is to draw a single Loop(Necklace) through every circle(Pearl)
           that never branches-off or crosses itself.
        2. The rules to pass Pearls are:
        3. Lines passing through White Pearls must go straight through them.
           However, at least at one side of the White Pearl(or both), they must
           do a 90 degree turn.
        4. Lines passing through Black Pearls must do a 90 degree turn in them.
           Then they must go straight in the next tile in both directions.
        5. Lines passing where there are no Pearls can do what they want.
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
                let p2 = p + MasyuGame.offset[i]
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
