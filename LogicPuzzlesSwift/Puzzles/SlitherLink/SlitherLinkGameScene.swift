//
//  SlitherLinkGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class SlitherLinkGameScene: GameScene<SlitherLinkGameState> {
    private(set) var gridNode: SlitherLinkGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addHintNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        let numberNode = SKLabelNode(text: String(n))
        numberNode.fontColor = s == .normal ? .white : s == .complete ? .green : .red
        numberNode.fontName = numberNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / numberNode.frame.width, gridNode.blockSize / numberNode.frame.height)
        numberNode.fontSize *= scalingFactor
        numberNode.verticalAlignmentMode = .center
        numberNode.position = point
        numberNode.name = nodeName
        gridNode.addChild(numberNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: SlitherLinkGameState, skView: SKView) {
        let game = game as! SlitherLinkGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = SlitherLinkGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // addHints
        for (p, n) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNumberNodeName = "hintNumber" + nodeNameSuffix
            addHintNumber(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNumberNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: SlitherLinkGameState, to stateTo: SlitherLinkGameState) {
        let markerOffset: CGFloat = 7.5
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                let hintNumberNodeName = "hintNumber" + nodeNameSuffix
                func removeNode(withName: String) {
                    gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                        node.removeFromParent()
                    }
                }
                func removeHintNumber() { removeNode(withName: hintNumberNodeName) }
                func addHorzLine(objType: SlitherLinkObject) {
                    guard objType != .empty else {return}
                    let pathToDraw = CGMutablePath()
                    let lineNode = SKShapeNode(path:pathToDraw)
                    switch objType {
                    case .line:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    case .marker:
                        pathToDraw.move(to: CGPoint(x: point.x - markerOffset, y: point.y + gridNode.blockSize / 2 + markerOffset))
                        pathToDraw.addLine(to: CGPoint(x: point.x + markerOffset, y: point.y + gridNode.blockSize / 2 - markerOffset))
                        pathToDraw.move(to: CGPoint(x: point.x + markerOffset, y: point.y + gridNode.blockSize / 2 + markerOffset))
                        pathToDraw.addLine(to: CGPoint(x: point.x - markerOffset, y: point.y + gridNode.blockSize / 2 - markerOffset))
                        lineNode.glowWidth = 2
                    default:
                        break
                    }
                    lineNode.path = pathToDraw
                    lineNode.strokeColor = .yellow
                    lineNode.name = horzLineNodeName
                    gridNode.addChild(lineNode)
                }
                func removeHorzLine(objType: SlitherLinkObject) {
                    if objType != .empty { removeNode(withName: horzLineNodeName) }
                }
                func addVertLine(objType: SlitherLinkObject) {
                    guard objType != .empty else {return}
                    let pathToDraw = CGMutablePath()
                    let lineNode = SKShapeNode(path:pathToDraw)
                    switch objType {
                    case .line:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y - gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    case .marker:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2 - markerOffset, y: point.y + markerOffset))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2 + markerOffset, y: point.y - markerOffset))
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2 - markerOffset, y: point.y - markerOffset))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2 + markerOffset, y: point.y + markerOffset))
                        lineNode.glowWidth = 2
                    default:
                        break
                    }
                    lineNode.path = pathToDraw
                    lineNode.strokeColor = .yellow
                    lineNode.name = vertlineNodeName
                    gridNode.addChild(lineNode)
                }
                func removeVertLine(objType: SlitherLinkObject) {
                    if objType != .empty { removeNode(withName: vertlineNodeName) }
                }
                var (o1, o2) = (stateFrom[p][1], stateTo[p][1])
                if o1 != o2 {
                    removeHorzLine(objType: o1)
                    addHorzLine(objType: o2)
                }
                (o1, o2) = (stateFrom[p][2], stateTo[p][2])
                if o1 != o2 {
                    removeVertLine(objType: o1)
                    addVertLine(objType: o2)
                }
                guard let s1 = stateFrom.pos2state[p], let s2 = stateTo.pos2state[p] else {continue}
                if s1 != s2 {
                    removeHintNumber()
                    addHintNumber(n: stateFrom.game.pos2hint[p]!, s: s2, point: point, nodeName: hintNumberNodeName)
                }
            }
        }
    }
}
