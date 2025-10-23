//
//  TatamiGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TatamiGameScene: GameScene<TatamiGameState> {
    var gridNode: TatamiGridNode {
        get { getGridNode() as! TatamiGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addCharacter(ch: Character, s: HintState, isHint: Bool, point: CGPoint, nodeName: String) {
        addLabel(text: String(ch), fontColor: isHint ? .gray : s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: TatamiGameState, skView: SKView) {
        let game = game as! TatamiGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TatamiGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                for dir in 1...2 {
                    guard game.dots[r, c][dir] == .line else {continue}
                    switch dir {
                    case 1:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    case 2:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y - gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    default:
                        break
                    }
                }
            }
        }
        lineNode.path = pathToDraw
        lineNode.name = "line"
        gridNode.addChild(lineNode)
        
        // add Characters
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let ch = game[p]
                guard ch != " " else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let charNodeName = "char" + nodeNameSuffix
                addCharacter(ch: ch, s: state.pos2state[p] ?? .normal, isHint: game[p] != " ", point: point, nodeName: charNodeName)
            }
        }

    }
    
    override func levelUpdated(from stateFrom: TatamiGameState, to stateTo: TatamiGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let charNodeName = "char" + nodeNameSuffix
                let (ch1, ch2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if ch1 != ch2 || s1 != s2 {
                    if (ch1 != " ") {
                        removeNode(withName: charNodeName)
                    }
                    if (ch2 != " ") {
                        addCharacter(ch: ch2, s: stateTo.pos2state[p] ?? .normal, isHint: stateTo.game[p] != " ", point: point, nodeName: charNodeName)
                    }
                }
            }
        }
    }
}
