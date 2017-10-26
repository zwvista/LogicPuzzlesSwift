//
//  RobotCrosswordsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class RobotCrosswordsGameScene: GameScene<RobotCrosswordsGameState> {
    var gridNode: RobotCrosswordsGridNode {
        get {return getGridNode() as! RobotCrosswordsGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(p: Position, isHorz: Bool, s: HintState, kh: RobotCrosswordsHint) {
        var point = gridNode.gridPosition(p: p)
        if isHorz {
            point.x += gridNode.blockSize / 2
        } else {
            point.y -= gridNode.blockSize / 2
        }
        let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (isHorz ? "h" : "v")
        let nodeName = "hint" + nodeNameSuffix
        let hintNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 8)
        hintNode.position = point
        hintNode.name = nodeName
        hintNode.strokeColor = s == .normal ? .white : s == .complete ? .green : .red
        hintNode.fillColor = kh == .consecutive ? .white : .black
        hintNode.glowWidth = 4.0
        gridNode.addChild(hintNode)
    }

    override func levelInitialized(_ game: AnyObject, state: RobotCrosswordsGameState, skView: SKView) {
        let game = game as! RobotCrosswordsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: RobotCrosswordsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        if game.bordered {
            let pathToDraw = CGMutablePath()
            let lineNode = SKShapeNode(path: pathToDraw)
            for r in 0..<game.rows + 1 {
                for c in 0..<game.cols + 1 {
                    let p = Position(r, c)
                    let point = gridNode.gridPosition(p: p)
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
            lineNode.strokeColor = .yellow
            lineNode.name = "line"
            gridNode.addChild(lineNode)
        }

        // addHint
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                for i in 0..<2 {
                    guard i == 0 && c != game.cols - 1 || i == 1 && r != game.rows - 1 else {continue}
                    let kh = (i == 0 ? game.pos2horzHint : game.pos2vertHint)[p]!
                    guard kh != .none else {continue}
                    addHint(p: Position(r, c), isHorz: i == 0, s: .normal, kh: kh)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: RobotCrosswordsGameState, to stateTo: RobotCrosswordsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (n1, n2) = (stateFrom[r, c], stateTo[r, c])
                if n1 != n2 {
                    if n1 != 0 {removeNode(withName: numberNodeName)}
                    if n2 != 0 {addLabel(text: String(n2), fontColor: .white, point: point, nodeName: numberNodeName)}
                }
                for i in 0..<2 {
                    guard i == 0 && c != stateFrom.game.cols - 1 || i == 1 && r != stateFrom.game.rows - 1 else {continue}
                    let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (i == 0 ? "h" : "v")
                    let hintNodeName = "hint" + nodeNameSuffix
                    let kh = (i == 0 ? stateFrom.game.pos2horzHint : stateFrom.game.pos2vertHint)[p]!
                    guard kh != .none else {continue}
                    let (s1, s2) = ((i == 0 ? stateFrom.pos2horzState : stateFrom.pos2vertState)[p] ?? .normal, (i == 0 ? stateTo.pos2horzState : stateTo.pos2vertState)[p] ?? .normal)
                    if s1 != s2 {
                        removeNode(withName: hintNodeName)
                        addHint(p: Position(r, c), isHorz: i == 0, s: s2, kh: kh)
                    }
                }
            }
        }
    }
}
