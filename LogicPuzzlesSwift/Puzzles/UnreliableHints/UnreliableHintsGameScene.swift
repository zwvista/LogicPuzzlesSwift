//
//  UnreliableHintsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class UnreliableHintsGameScene: GameScene<UnreliableHintsGameState> {
    var gridNode: UnreliableHintsGridNode {
        get { getGridNode() as! UnreliableHintsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize / 2, height: gridNode.blockSize / 2))
    }
    
    func getCenterPoint(p: Position, dir: Int) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = switch dir {
        case 0: (CGFloat(p.col) + CGFloat(0.5)) * gridNode.blockSize + offset
        case 1: (CGFloat(p.col) + CGFloat(0.75)) * gridNode.blockSize + offset
        case 2: (CGFloat(p.col) + CGFloat(0.5)) * gridNode.blockSize + offset
        default: (CGFloat(p.col) + CGFloat(0.25)) * gridNode.blockSize + offset
        }
        let y = switch dir {
        case 0: -((CGFloat(p.row) + CGFloat(0.25)) * gridNode.blockSize + offset)
        case 1: -((CGFloat(p.row) + CGFloat(0.5)) * gridNode.blockSize + offset)
        case 2: -((CGFloat(p.row) + CGFloat(0.75)) * gridNode.blockSize + offset)
        default: -((CGFloat(p.row) + CGFloat(0.5)) * gridNode.blockSize + offset)
        }
        return CGPoint(x: x, y: y)
    }
    
    func getImageName(dir: Int) -> String {
        switch dir {
        case 0: "arrow_cyan_up"
        case 1: "arrow_cyan_right"
        case 2: "arrow_cyan_down"
        default: "arrow_cyan_left"
        }
    }

    override func levelInitialized(_ game: AnyObject, state: UnreliableHintsGameState, skView: SKView) {
        let game = game as! UnreliableHintsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: UnreliableHintsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, hint) in game.pos2hint {
            let dir2 = hint.dir, dir1 = (dir2 + 2) % 4
            let point = gridNode.centerPoint(p: p)
            let point1 = getCenterPoint(p: p, dir: dir1)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let arrowNodeName = "arrow" + nodeNameSuffix
            addHint(n: hint.num, s: state.pos2stateHint[p]!, point: point1, nodeName: hintNodeName)
            addImage(imageNamed: getImageName(dir: dir2), color: .red, colorBlendFactor: 0.0, point: point, nodeName: arrowNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: UnreliableHintsGameState, to stateTo: UnreliableHintsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let shadedNodeName = "shaded" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let arrowNodeName = "arrow" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                let (s3, s4) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                if o1 != o2 || s1 != s2 {
                    switch o1 {
                    case .shaded:
                        removeNode(withName: shadedNodeName)
                    case .marker:
                        removeNode(withName: markerNodeName)
                    default:
                        break
                    }
                    switch o2 {
                    case .shaded:
                        let shadedNode = SKSpriteNode(color: .lightGray, size: coloredRectSize())
                        shadedNode.position = point
                        shadedNode.name = shadedNodeName
                        gridNode.addChild(shadedNode)
                    case .marker:
                        addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
                    default:
                        break
                    }
                }
                if s3 != s4 || s3 != nil && (o1 == .shaded || o2 == .shaded) {
                    removeNode(withName: hintNodeName)
                    removeNode(withName: arrowNodeName)
                    let hint = stateFrom.game.pos2hint[p]!
                    let dir2 = hint.dir, dir1 = (dir2 + 2) % 4
                    let point1 = getCenterPoint(p: p, dir: dir1)
                    addHint(n: hint.num, s: s4!, point: point1, nodeName: hintNodeName)
                    addImage(imageNamed: getImageName(dir: dir2), color: .red, colorBlendFactor: 0.0, point: point, nodeName: arrowNodeName)
                }
            }
        }
    }
}
