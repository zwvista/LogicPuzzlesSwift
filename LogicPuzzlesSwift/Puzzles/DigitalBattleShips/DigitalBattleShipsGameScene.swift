//
//  DigitalBattleShipsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class DigitalBattleShipsGameScene: GameScene<DigitalBattleShipsGameState> {
    var gridNode: DigitalBattleShipsGridNode {
        get { getGridNode() as! DigitalBattleShipsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addBattleShip(color: SKColor, point: CGPoint, obj: DigitalBattleShipsObject, nodeName: String) {
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
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.gridPoint(p: p)
        guard n >= 0 else {return}
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: hintNodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: DigitalBattleShipsGameState, skView: SKView) {
        let game = game as! DigitalBattleShipsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: DigitalBattleShipsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            let p = Position(r, game.cols)
            let n = state.game.row2hint[r]
            addHint(p: p, n: n, s: state.row2state[r])
        }
        for c in 0..<game.cols {
            let p = Position(game.rows, c)
            let n = state.game.col2hint[c]
            addHint(p: p, n: n, s: state.col2state[c])
        }
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let n = state.game[r, c]
                addHint(p: p, n: n, s: .normal)
            }
        }

        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                switch state[p] {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: DigitalBattleShipsGameState, to stateTo: DigitalBattleShipsGameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows {
            let p = Position(r, stateFrom.cols)
            let n = stateFrom.game.row2hint[r]
            if stateFrom.row2state[r] != stateTo.row2state[r] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.row2state[r])
            }
        }
        for c in 0..<stateFrom.cols {
            let p = Position(stateFrom.rows, c)
            let n = stateFrom.game.col2hint[c]
            if stateFrom.col2state[c] != stateTo.col2state[c] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.col2state[c])
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let battleShipNodeName = "battleShip" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                func removeBattleShip() { removeNode(withName: battleShipNodeName) }
                func addMarker() { addDotMarker2(color: .green, point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                let (o1, o2) = (stateFrom[r, c], stateTo[r, c])
                guard o1 != o2 else {continue}
                switch o1 {
                case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                    removeBattleShip()
                case .forbidden:
                    removeForbidden()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit:
                    removeHint(p: p)
                    addBattleShip(color: .gray, point: point, obj: o2, nodeName: battleShipNodeName)
                    addHint(p: p, n: stateFrom.game[p], s: .normal)
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .marker:
                    addMarker()
                default:
                    break
                }                
            }
        }
    }
}
