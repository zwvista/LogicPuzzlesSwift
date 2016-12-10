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
    
    func addLabel(parentNode: GridNode, text: String, fontColor: SKColor, point: CGPoint, nodeName: String) {
        let labelNode = SKLabelNode(text: text)
        labelNode.fontColor = fontColor
        labelNode.fontName = labelNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(parentNode.blockSize / labelNode.frame.width, parentNode.blockSize / labelNode.frame.height)
        labelNode.fontSize *= scalingFactor
        labelNode.verticalAlignmentMode = .center
        labelNode.position = point
        labelNode.name = nodeName
        parentNode.addChild(labelNode)
    }
}
