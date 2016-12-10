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
}
