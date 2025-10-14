//
//  HidokuGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class HidokuGameScene: GameScene<HidokuGameState> {
    var gridNode: HidokuGridNode {
        get { getGridNode() as! HidokuGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: n, fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, sampleText: "10")
    }
    
    func addArrow(n: Int, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: n == 8 ? "star_yellow" : getArrowImageName(n: n), color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize / 2, height: gridNode.blockSize / 2))
    }

    override func levelInitialized(_ game: AnyObject, state: HidokuGameState, skView: SKView) {
        let game = game as! HidokuGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: HidokuGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addNumbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let (n, s) = (state[p].destructured)
                if n != HidokuGame.PUZ_UNKNOWN && n != HidokuGame.PUZ_FORBIDDEN {
                    let numberNodeName = "number" + nodeNameSuffix
                    addNumber(n: String(n), s: s, point: point, nodeName: numberNodeName)
                    let markerNodeName = "marker" + nodeNameSuffix
                    addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
                }
                if n == HidokuGame.PUZ_FORBIDDEN {
                    let forbiddenNodeName = "forbidden" + nodeNameSuffix
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                }
            }
        }
    }
    
    override func stateChanged(from stateFrom: HidokuGameState?, to stateTo: HidokuGameState) {
        let (p1f, p1t) = (stateFrom?.focusPos, stateTo.focusPos!)
        if p1f != p1t {
            let rectNodeName = "focusPos"
            removeNode(withName: rectNodeName)
            let rectNode = SKShapeNode(rectOf: coloredRectSize())
            rectNode.name = rectNodeName
            rectNode.position = gridNode.gridPosition(p: p1t)
            rectNode.strokeColor = UIColor(r: 232, g: 168, b: 108)
            rectNode.lineWidth = 4
            gridNode.addChild(rectNode)
        }
        guard let stateFrom = stateFrom else {return}
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let ((n1, s1), (n2, s2)) = (stateFrom[p].destructured, stateTo[p].destructured)
                guard n1 != n2 || s1 != s2 else {continue}
                let numberNodeName = "number" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                func removeNumber() { removeNode(withName: numberNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                switch n1 {
                case HidokuGame.PUZ_UNKNOWN: break
                case HidokuGame.PUZ_FORBIDDEN: removeForbidden()
                default: removeNumber()
                }
                switch n2 {
                case HidokuGame.PUZ_UNKNOWN: break
                case HidokuGame.PUZ_FORBIDDEN: addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                default: addNumber(n: String(n2), s: s2, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
}
