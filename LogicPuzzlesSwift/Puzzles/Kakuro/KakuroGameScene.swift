//
//  KakuroGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class KakuroGameScene: GameScene<KakuroGameState> {
    var gridNode: KakuroGridNode {
        get { getGridNode() as! KakuroGridNode }
        set { setGridNode(gridNode: newValue) }
    }

    func addHint(p: Position, n: Int, isHorz: Bool, s: HintState) {
        var point = gridNode.gridPoint(p: p)
        point.x += gridNode.blockSize / 4 * (isHorz ? 1 : -1)
        point.y -= gridNode.blockSize / 4 * (isHorz ? -1 : 1)
        let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (isHorz ? "h" : "v")
        let nodeName = "hint" + nodeNameSuffix
        let labelNode = SKLabelNode(text: "10")
        labelNode.fontColor = s == .normal ? .black : s == .complete ? .green : .red
        labelNode.fontName = labelNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(size.width / labelNode.frame.width, size.height / labelNode.frame.height)
        labelNode.fontSize *= scalingFactor * 0.08
        labelNode.verticalAlignmentMode = .center
        labelNode.position = point
        labelNode.name = nodeName
        labelNode.text = String(n)
        gridNode.addChild(labelNode)
    }

    override func levelInitialized(_ game: AnyObject, state: KakuroGameState, skView: SKView) {
        let game = game as! KakuroGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: KakuroGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path:pathToDraw)
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                guard game.pos2num[p] == nil else {continue}
                let point = gridNode.gridPoint(p: p)
                let borderNode = SKShapeNode(rectOf: CGSize(width: blockSize - 4, height: blockSize - 4))
                borderNode.position = point
                borderNode.fillColor = .lightGray
                gridNode.addChild(borderNode)
                pathToDraw.move(to: CGPoint(x: point.x - blockSize, y: point.y + blockSize))
                pathToDraw.addLine(to: CGPoint(x: point.x + blockSize, y: point.y - blockSize))
                if let n = game.pos2vertHint[p] {
                    addHint(p: p, n: n, isHorz: false, s: .normal)
                }
                if let n = game.pos2horzHint[p] {
                    addHint(p: p, n: n, isHorz: true, s: .normal)
                }
            }
        }
        lineNode.path = pathToDraw
        lineNode.strokeColor = .black
        gridNode.addChild(lineNode)
    }
    
    override func levelUpdated(from stateFrom: KakuroGameState, to stateTo: KakuroGameState) {
        func undateHint(p: Position, n: Int, isHorz: Bool, s1: HintState, s2: HintState) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)" + (isHorz ? "h" : "v")
            let nodeName = "hint" + nodeNameSuffix
            if s1 != s2 {
                removeNode(withName: nodeName)
                addHint(p: p, n: n, isHorz: isHorz, s: s2)
            }
        }
        for (p, n) in stateFrom.game.pos2vertHint {
            undateHint(p: p, n: n, isHorz: false, s1: stateFrom.pos2vertState[p]!, s2: stateTo.pos2vertState[p]!)
        }
        for (p, n) in stateFrom.game.pos2horzHint {
            undateHint(p: p, n: n, isHorz: true, s1: stateFrom.pos2horzState[p]!, s2: stateTo.pos2horzState[p]!)
        }
        for p in stateFrom.pos2num.keys {
            let point = gridNode.gridPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let nodeName = "num" + nodeNameSuffix
            let (n1, n2) = (stateFrom.pos2num[p]!, stateTo.pos2num[p]!)
            if n1 != n2 {
                if n1 != 0 { removeNode(withName: nodeName) }
                if n2 != 0 { addLabel(text: String(n2), fontColor: .white, point: point, nodeName: nodeName) }
            }
        }
    }
}
