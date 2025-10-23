//
//  MineShipsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MineShipsGameScene: GameScene<MineShipsGameState> {
    var gridNode: MineShipsGridNode {
        get { getGridNode() as! MineShipsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addBattleShip(color: SKColor, point: CGPoint, obj: MineShipsObject, nodeName: String) {
        let battleShipNode = SKShapeNode()
        let bezierPath = UIBezierPath()
        let radius = gridNode.blockSize * CGFloat(0.5) - CGFloat(1)
        switch obj {
        case .battleShipTop:
            bezierPath.move(to: CGPoint(x: point.x - radius, y: point.y - radius))
            bezierPath.addLine(to: CGPoint(x: point.x + radius, y: point.y - radius))
            bezierPath.addLine(to: CGPoint(x: point.x + radius, y: point.y))
            bezierPath.addArc(withCenter: point, radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
        case .battleShipBottom:
            bezierPath.move(to: CGPoint(x: point.x - radius, y: point.y + radius))
            bezierPath.addLine(to: CGPoint(x: point.x + radius, y: point.y + radius))
            bezierPath.addLine(to: CGPoint(x: point.x + radius, y: point.y))
            bezierPath.addArc(withCenter: point, radius: radius, startAngle: 0, endAngle: .pi, clockwise: false)
        case .battleShipLeft:
            bezierPath.move(to: CGPoint(x: point.x + radius, y: point.y - radius))
            bezierPath.addLine(to: CGPoint(x: point.x + radius, y: point.y + radius))
            bezierPath.addLine(to: CGPoint(x: point.x, y: point.y + radius))
            bezierPath.addArc(withCenter: point, radius: radius, startAngle: .pi / 2, endAngle: .pi / 2 * 3, clockwise: true)
        case .battleShipRight:
            bezierPath.move(to: CGPoint(x: point.x - radius, y: point.y - radius))
            bezierPath.addLine(to: CGPoint(x: point.x - radius, y: point.y + radius))
            bezierPath.addLine(to: CGPoint(x: point.x, y: point.y + radius))
            bezierPath.addArc(withCenter: point, radius: radius, startAngle: .pi / 2, endAngle: .pi / 2 * 3, clockwise: false)
        case .battleShipMiddle:
            bezierPath.move(to: CGPoint(x: point.x - radius, y: point.y + radius))
            bezierPath.addLine(to: CGPoint(x: point.x + radius, y: point.y + radius))
            bezierPath.addLine(to: CGPoint(x: point.x + radius, y: point.y - radius))
            bezierPath.addLine(to: CGPoint(x: point.x - radius, y: point.y - radius))
        case .battleShipUnit:
            bezierPath.addArc(withCenter: point, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        default:
            break
        }
        bezierPath.close()
        battleShipNode.path = bezierPath.cgPath
        battleShipNode.fillColor = color
        battleShipNode.strokeColor = .gray
        battleShipNode.name = nodeName
        gridNode.addChild(battleShipNode)
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: MineShipsGameState, skView: SKView) {
        let game = game as! MineShipsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MineShipsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            guard case let .hint(state: s) = state[p] else {continue}
            let point = gridNode.gridPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }

        // addForbidden
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                guard case .forbidden = state[p] else {continue}
                let point = gridNode.gridPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: MineShipsGameState, to stateTo: MineShipsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let battleShipNodeName = "battleShip" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func removeHint() { removeNode(withName: hintNodeName) }
                func removeBattleShip() { removeNode(withName: battleShipNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                let (ot1, ot2) = (stateFrom[r, c], stateTo[r, c])
                guard String(describing: ot1) != String(describing: ot2) else {continue}
                switch ot1 {
                case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                    removeBattleShip()
                case .forbidden:
                    removeForbidden()
                case .marker:
                    removeMarker()
                case .hint:
                    removeHint()
                default:
                    break
                }
                switch ot2 {
                case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                    addBattleShip(color: .white, point: point, obj: ot2, nodeName: battleShipNodeName)
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .marker:
                    addMarker()
                case let .hint(s):
                    let n = stateTo.game.pos2hint[Position(r, c)]!
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                default:
                    break
                }                
            }
        }
    }
}
