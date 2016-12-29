//
//  GameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GameScene<GS: GameStateBase>: SKScene {
    private var gridNode: GridNode!
    func getGridNode() -> GridNode! {return gridNode}
    func setGridNode(gridNode: GridNode) {self.gridNode = gridNode}

    func levelInitialized(_ game: AnyObject, state: GS, skView: SKView) {}
    func levelUpdated(from stateFrom: GS, to stateTo: GS) {}
    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
    
    func addGrid(gridNode: GridNode, point: CGPoint) {
        scaleMode = .resizeFill
        self.gridNode = gridNode
        gridNode.position = point
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
    }
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func removeNode(withName: String) {
        gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
            node.removeFromParent()
        }
    }

    func addLabel(text: String, fontColor: SKColor, point: CGPoint, nodeName: String) {
        let labelNode = SKLabelNode(text: text)
        labelNode.fontColor = fontColor
        labelNode.fontName = labelNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / labelNode.frame.width, gridNode.blockSize / labelNode.frame.height)
        labelNode.fontSize *= scalingFactor * 0.8
        labelNode.verticalAlignmentMode = .center
        labelNode.position = point
        labelNode.name = nodeName
        gridNode.addChild(labelNode)
    }
    
    func addImage(imageNamed: String, color: SKColor, colorBlendFactor: CGFloat, point: CGPoint, nodeName: String) {
        let lightbulbNode = SKSpriteNode(imageNamed: imageNamed)
        let scalingFactor = min(gridNode.blockSize / lightbulbNode.frame.width, gridNode.blockSize / lightbulbNode.frame.height)
        lightbulbNode.setScale(scalingFactor)
        lightbulbNode.position = point
        lightbulbNode.name = nodeName
        lightbulbNode.color = color
        lightbulbNode.colorBlendFactor = colorBlendFactor
        gridNode.addChild(lightbulbNode)
    }
    
    private func addDotMarker2(color: SKColor, point: CGPoint, nodeName: String) {
        let markerNode = SKShapeNode(circleOfRadius: 5)
        markerNode.position = point
        markerNode.name = nodeName
        markerNode.strokeColor = color
        markerNode.glowWidth = 1.0
        markerNode.fillColor = color
        gridNode.addChild(markerNode)
    }
    
    func addDotMarker(point: CGPoint, nodeName: String) {
        addDotMarker2(color: .white, point: point, nodeName: nodeName)
    }
    
    func addForbiddenMarker(point: CGPoint, nodeName: String) {
        addDotMarker2(color: .red, point: point, nodeName: nodeName)
    }
    
    func addCircleMarker(point: CGPoint, nodeName: String) {
        let markerNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 2)
        markerNode.position = point
        markerNode.name = nodeName
        markerNode.strokeColor = .white
        markerNode.glowWidth = 1.0
        gridNode.addChild(markerNode)
    }
    
    func addHorzLine(objType: GridLineObject, color: SKColor, point: CGPoint, nodeName: String) {
        let markerOffset: CGFloat = 7.5
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
        lineNode.strokeColor = color
        lineNode.name = nodeName
        gridNode.addChild(lineNode)
    }
    
    func addVertLine(objType: GridLineObject, color: SKColor, point: CGPoint, nodeName: String) {
        let markerOffset: CGFloat = 7.5
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
        lineNode.strokeColor = color
        lineNode.name = nodeName
        gridNode.addChild(lineNode)
    }
}
