//
//  SlantedMazeGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class SlantedMazeGameScene: GameScene<SlantedMazeGameState> {
    var gridNode: SlantedMazeGridNode {
        get { getGridNode() as! SlantedMazeGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        let markerNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 4)
        markerNode.position = point
        markerNode.name = nodeName
        markerNode.strokeColor = .yellow
        markerNode.fillColor = .black
        markerNode.glowWidth = 1.0
        gridNode.addChild(markerNode)
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize / 2, height: gridNode.blockSize / 2))
    }

    override func levelInitialized(_ game: AnyObject, state: SlantedMazeGameState, skView: SKView) {
        let game = game as! SlantedMazeGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: SlantedMazeGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
                
        for (p, n) in game.pos2hint {
            let point = gridNode.cornerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: SlantedMazeGameState, to stateTo: SlantedMazeGameState) {
        let game = stateFrom.game
        var rng = Set<Position>()
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let nodeNameSuffix = "-\(r)-\(c)"
                let slashNodeName = "slash" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard o1 != o2 else {continue}
                if o1 != .empty { removeNode(withName: slashNodeName) }
                func addSlash(p1: Position, p2: Position) {
                    let pathToDraw = CGMutablePath()
                    pathToDraw.move(to: gridNode.cornerPoint(p: p1))
                    pathToDraw.addLine(to: gridNode.cornerPoint(p: p2))
                    let slashNode = SKShapeNode(path:pathToDraw)
                    slashNode.strokeColor = .green
                    slashNode.lineWidth = 4
                    slashNode.name = slashNodeName
                    gridNode.addChild(slashNode)
                    rng.insert(p1)
                    rng.insert(p2)
                }
                switch o2 {
                case .forward:
                    addSlash(p1: p, p2: p + SlantedMazeGame.offset2[3])
                case .backward:
                    addSlash(p1: p + SlantedMazeGame.offset2[1], p2: p + SlantedMazeGame.offset2[2])
                case .empty:
                    break
                }
            }
        }
        for (p, n) in game.pos2hint {
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            guard s1 != s2 || rng.contains(p) else {continue}
            let point = gridNode.cornerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
            addHint(n: n, s: s2, point: point, nodeName: hintNodeName)
        }
    }
}
