//
//  TapaGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TapaGameScene: GameScene<TapaGameState> {
    var gridNode: TapaGridNode {
        get {return getGridNode() as! TapaGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(arr: [Int], s: HintState, point: CGPoint, nodeName: String) {
        let blockSize = gridNode.blockSize!
        let fontColor: SKColor = s == .normal ? .white : s == .complete ? .green : .red
        let size2 = CGSize(width: blockSize / 2, height: blockSize / 2)
        switch arr.count {
        case 1:
            addLabel(text: String(arr[0]), fontColor: fontColor, point: point, nodeName: nodeName)
        case 2:
            addLabel(text: String(arr[0]), fontColor: fontColor, point: CGPoint(x: point.x - blockSize / 4, y: point.y + blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: String(arr[1]), fontColor: fontColor, point: CGPoint(x: point.x + blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
        case 3:
            addLabel(text: String(arr[0]), fontColor: fontColor, point: CGPoint(x: point.x, y: point.y + blockSize / 4), nodeName: nodeName, size: CGSize(width: blockSize, height: blockSize / 2))
            addLabel(text: String(arr[1]), fontColor: fontColor, point: CGPoint(x: point.x - blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: String(arr[2]), fontColor: fontColor, point: CGPoint(x: point.x + blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
        case 4:
            addLabel(text: String(arr[0]), fontColor: fontColor, point: CGPoint(x: point.x - blockSize / 4, y: point.y + blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: String(arr[1]), fontColor: fontColor, point: CGPoint(x: point.x + blockSize / 4, y: point.y + blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: String(arr[2]), fontColor: fontColor, point: CGPoint(x: point.x - blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
            addLabel(text: String(arr[3]), fontColor: fontColor, point: CGPoint(x: point.x + blockSize / 4, y: point.y - blockSize / 4), nodeName: nodeName, size: size2)
        default:
            break
        }
    }
    
    override func levelInitialized(_ game: AnyObject, state: TapaGameState, skView: SKView) {
        let game = game as! TapaGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TapaGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, arr) in game.pos2hint {
            guard case let .hint(state: s) = state[p] else {continue}
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(arr: arr, s: s, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: TapaGameState, to stateTo: TapaGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let point = gridNode.gridPosition(p: Position(r, c))
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
                guard String(describing: ot1) != String(describing: ot2) else {continue}
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
}
