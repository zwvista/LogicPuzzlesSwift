//
//  BalancedTapasGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BalancedTapasGameScene: GameScene<BalancedTapasGameState> {
    var gridNode: BalancedTapasGridNode {
        get { getGridNode() as! BalancedTapasGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(arr: [Int], s: HintState, point: CGPoint, nodeName: String) {
        func hint2Str(i: Int) -> String {
            let n = arr[i]
            return n == -1 ? "?" : String(n)
        }
        let blockSize = gridNode.blockSize!
        let fontColor: SKColor = s == .normal ? .white : s == .complete ? .green : .red
        let size2 = CGSize(width: blockSize / 2, height: blockSize / 2)
        switch arr.count {
        case 1:
            addLabel(text: hint2Str(i: 0), fontColor: fontColor, point: point, nodeName: nodeName)
        case 2:
            addLabel(text: hint2Str(i: 0), fontColor: fontColor, point: CGPoint(x: point.x - blockSize / 4, y: point.y + blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: hint2Str(i: 1), fontColor: fontColor, point: CGPoint(x: point.x + blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
        case 3:
            addLabel(text: hint2Str(i: 0), fontColor: fontColor, point: CGPoint(x: point.x, y: point.y + blockSize / 4), nodeName: nodeName, size: CGSize(width: blockSize, height: blockSize / 2))
            addLabel(text: hint2Str(i: 1), fontColor: fontColor, point: CGPoint(x: point.x - blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: hint2Str(i: 2), fontColor: fontColor, point: CGPoint(x: point.x + blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
        case 4:
            addLabel(text: hint2Str(i: 0), fontColor: fontColor, point: CGPoint(x: point.x - blockSize / 4, y: point.y + blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: hint2Str(i: 1), fontColor: fontColor, point: CGPoint(x: point.x + blockSize / 4, y: point.y + blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: hint2Str(i: 2), fontColor: fontColor, point: CGPoint(x: point.x - blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: hint2Str(i: 3), fontColor: fontColor, point: CGPoint(x: point.x + blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
        default:
            break
        }
    }
    
    override func levelInitialized(_ game: AnyObject, state: BalancedTapasGameState, skView: SKView) {
        let game = game as! BalancedTapasGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: BalancedTapasGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, arr) in game.pos2hint {
            guard case let .hint(state: s) = state[p] else {continue}
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(arr: arr, s: s, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: BalancedTapasGameState, to stateTo: BalancedTapasGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let point = gridNode.centerPoint(p: Position(r, c))
                let nodeNameSuffix = "-\(r)-\(c)"
                let wallNodeName = "wall" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func removeHint() { removeNode(withName: hintNodeName) }
                func addWall() {
                    let wallNode = SKSpriteNode(color: .white, size: coloredRectSize())
                    wallNode.position = point
                    wallNode.name = wallNodeName
                    gridNode.addChild(wallNode)
                }
                func removeWall() { removeNode(withName: wallNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (ot1, ot2) = (stateFrom[r, c], stateTo[r, c])
                if String(describing: ot1) != String(describing: ot2) {
                    switch ot1 {
                    case .wall:
                        removeWall()
                    case .marker:
                        removeMarker()
                    case .hint:
                        removeHint()
                    default:
                        break
                    }
                    switch ot2 {
                    case .wall:
                        addWall()
                    case .marker:
                        addMarker()
                    case let .hint(s):
                        let arr = stateTo.game.pos2hint[Position(r, c)]!
                        addHint(arr: arr, s: s, point: point, nodeName: hintNodeName)
                    default:
                        break
                    }
                }
            }
        }
        let lineNodeName = "line"
        removeNode(withName: lineNodeName)
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<stateFrom.rows {
            let c = stateFrom.game.left
            let point = gridNode.centerPoint(p: Position(r, c))
            let x = point.x - gridNode.blockSize / 2 - (c > stateFrom.game.right ? gridNode.blockSize / 2 : 0)
            pathToDraw.move(to: CGPoint(x: x, y: point.y + gridNode.blockSize / 2))
            pathToDraw.addLine(to: CGPoint(x: x, y: point.y - gridNode.blockSize / 2))
        }
        lineNode.glowWidth = 4
        lineNode.path = pathToDraw
        lineNode.strokeColor = .yellow
        gridNode.addChild(lineNode)
    }
}
