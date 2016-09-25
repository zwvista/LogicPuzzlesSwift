//
//  GameScene.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    private(set) var gridNode: GridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addGrid(to view: SKView, rows: Int, cols: Int, blockSize: CGFloat) {
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = GridNode(blockSize: blockSize, rows: rows, cols: cols)
        gridNode.position = CGPoint(x: view.frame.midX - gridNode.blockSize * CGFloat(gridNode.cols) / 2 - offset, y: view.frame.midY + gridNode.blockSize * CGFloat(gridNode.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
    }
    
    func addWalls(from state: GameState) {
        for row in 0 ..< state.size.row {
            for col in 0 ..< state.size.col {
                let p = Position(row, col)
                guard case .wall(let n) = state[p].objType else {continue}
                let point = gridNode.gridPosition(p: p)
                let wallNode = SKSpriteNode(color: SKColor.white, size: coloredRectSize())
                wallNode.position = point
                wallNode.name = "wall"
                gridNode.addChild(wallNode)
                guard n >= 0 else {continue}
                let numberNode = SKLabelNode(text: String(n))
                numberNode.fontColor = SKColor.black
                numberNode.fontName = numberNode.fontName! + "-Bold"
                numberNode.fontSize *= CGFloat(gridNode.blockSize) / 60.0
                numberNode.verticalAlignmentMode = .center
                numberNode.position = point
                numberNode.name = "wall"
                gridNode.addChild(numberNode)
            }
        }
    }
    
    func process(from stateFrom: GameState, to stateTo: GameState) {
        for row in 0 ..< stateFrom.size.row {
            for col in 0 ..< stateFrom.size.col {
                let point = gridNode.gridPosition(p: Position(row, col))
                let nodeNameSuffix = "-\(row)-\(col)"
                let lightCellNodeName = "lightCell" + nodeNameSuffix
                let lightbulbNodeName = "lightbulb" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func removeNode(withName: String) {
                    gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                        node.removeFromParent()
                    }
                }
                func addLightCell() {
                    let lightCellNode = SKSpriteNode(color: SKColor.yellow, size: coloredRectSize())
                    lightCellNode.position = point
                    lightCellNode.name = lightCellNodeName
                    gridNode.addChild(lightCellNode)
                }
                func removeLightCell() { removeNode(withName: lightCellNodeName) }
                func addLightbulb() {
                    let lightbulbNode = SKSpriteNode(imageNamed: "lightbulb")
                    lightbulbNode.setScale(CGFloat(gridNode.blockSize) / 300.0)
                    lightbulbNode.position = point
                    lightbulbNode.name = lightbulbNodeName
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
                default:
                    break
                }
                switch ot2 {
                case .lightbulb:
                    addLightbulb()
                case .marker:
                    addMarker()
                default:
                    break
                }
            }
        }
    }
}
