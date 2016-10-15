//
//  LightUpGameScene.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LightUpGameScene: SKScene {
    private(set) var gridNode: LightUpGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addGrid(to view: SKView, rows: Int, cols: Int, blockSize: CGFloat) {
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = LightUpGridNode(blockSize: blockSize, rows: rows, cols: cols)
        gridNode.position = CGPoint(x: view.frame.midX - gridNode.blockSize * CGFloat(gridNode.cols) / 2 - offset, y: view.frame.midY + gridNode.blockSize * CGFloat(gridNode.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
    }
    
    func addWalls(from state: LightUpGameState) {
        for row in 0 ..< state.rows {
            for col in 0 ..< state.cols {
                let p = Position(row, col)
                guard case let .wall(s) = state[p].objType else {continue}
                let n = state.game.wall2Lightbulbs[p]!
                let point = gridNode.gridPosition(p: p)
                let wallNode = SKSpriteNode(color: SKColor.white, size: coloredRectSize())
                wallNode.position = point
                wallNode.name = "wall"
                gridNode.addChild(wallNode)
                guard n >= 0 else {continue}
                let nodeNameSuffix = "-\(row)-\(col)"
                let wallNumberNodeName = "wallNumber" + nodeNameSuffix
                addWallNumber(n: n, s: s, point: point, nodeName: wallNumberNodeName)
            }
        }
    }
    
    func addWallNumber(n: Int, s: LightUpWallState, point: CGPoint, nodeName: String) {
        let numberNode = SKLabelNode(text: String(n))
        numberNode.fontColor = s == .normal ? SKColor.black : s == .complete ? SKColor.green : SKColor.red
        numberNode.fontName = numberNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / numberNode.frame.width, gridNode.blockSize / numberNode.frame.height)
        numberNode.fontSize *= scalingFactor
        numberNode.verticalAlignmentMode = .center
        numberNode.position = point
        numberNode.name = nodeName
        gridNode.addChild(numberNode)
    }
    
    func process(from stateFrom: LightUpGameState, to stateTo: LightUpGameState) {
        for row in 0 ..< stateFrom.rows {
            for col in 0 ..< stateFrom.cols {
                let point = gridNode.gridPosition(p: Position(row, col))
                let nodeNameSuffix = "-\(row)-\(col)"
                let lightCellNodeName = "lightCell" + nodeNameSuffix
                let lightbulbNodeName = "lightbulb" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let wallNumberNodeName = "wallNumber" + nodeNameSuffix
                func removeNode(withName: String) {
                    gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                        node.removeFromParent()
                    }
                }
                func removeWallNumber() { removeNode(withName: wallNumberNodeName) }
                func addLightCell() {
                    let lightCellNode = SKSpriteNode(color: SKColor.yellow, size: coloredRectSize())
                    lightCellNode.position = point
                    lightCellNode.name = lightCellNodeName
                    gridNode.addChild(lightCellNode)
                }
                func removeLightCell() { removeNode(withName: lightCellNodeName) }
                func addLightbulb(s: LightUpLightbulbState) {
                    let lightbulbNode = SKSpriteNode(imageNamed: "lightbulb")
                    let scalingFactor = min(gridNode.blockSize / lightbulbNode.frame.width, gridNode.blockSize / lightbulbNode.frame.height)
                    lightbulbNode.setScale(scalingFactor)
                    lightbulbNode.position = point
                    lightbulbNode.name = lightbulbNodeName
                    lightbulbNode.color = SKColor.red
                    lightbulbNode.colorBlendFactor = s == .normal ? 0.0 : 0.2
                    gridNode.addChild(lightbulbNode)
                }
                func removeLightbulb() { removeNode(withName: lightbulbNodeName) }
                func addMarker() {
                    let markerNode = SKShapeNode(circleOfRadius: 5)
                    markerNode.position = point
                    markerNode.name = markerNodeName
                    markerNode.strokeColor = SKColor.white
                    markerNode.glowWidth = 1.0
                    markerNode.fillColor = SKColor.white
                    gridNode.addChild(markerNode)
                }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (x, y) = (stateFrom[row, col].lightness, stateTo[row, col].lightness)
                if x > 0 && y == 0 {
                    removeLightCell()
                } else if x == 0 && y > 0 {
                    addLightCell()
                }
                let (ot1, ot2) = (stateFrom[row, col].objType, stateTo[row, col].objType)
                guard String(describing: ot1) != String(describing: ot2) else {continue}
                switch ot1 {
                case .lightbulb:
                    removeLightbulb()
                case .marker:
                    removeMarker()
                case .wall:
                    removeWallNumber()
                default:
                    break
                }
                switch ot2 {
                case let .lightbulb(s):
                    addLightbulb(s: s)
                case .marker:
                    addMarker()
                case let .wall(s):
                    let n = stateTo.game.wall2Lightbulbs[Position(row, col)]!
                    addWallNumber(n: n, s: s, point: point, nodeName: wallNumberNodeName)
                default:
                    break
                }
            }
        }
    }
}
