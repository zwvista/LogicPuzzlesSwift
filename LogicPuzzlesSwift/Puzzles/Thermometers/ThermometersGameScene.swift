//
//  ThermometersGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ThermometersGameScene: GameScene<ThermometersGameState> {
    var gridNode: ThermometersGridNode {
        get { getGridNode() as! ThermometersGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.gridPosition(p: p)
        guard n >= 0 else {return}
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: hintNodeName)
    }
    
    func addThermometer(ch: Character, filled: Bool, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        let n = ThermometersGame.parts.getIndexOf(ch)!
        let (m, degrees) = n < 4 ? (1, (6 - n) % 4 * 90) : n < 8 ? (3, (8 - n) % 4 * 90) : (2, (n - 8) * 90)
        let imageName = "thermometer\(m)\(filled ? "B" : "A")"
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName, zRotation: (degrees.toDouble * Double.pi / 180.0).toCGFloat)
    }
    
    override func levelInitialized(_ game: AnyObject, state: ThermometersGameState, skView: SKView) {
        let game = game as! ThermometersGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ThermometersGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset))
        
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
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let thermometerNodeName = "thermometer" + nodeNameSuffix
                addThermometer(ch: game[p], filled: false, s: .normal, point: point, nodeName: thermometerNodeName)
                if case .forbidden = state[p] {
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: ThermometersGameState, to stateTo: ThermometersGameState) {
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
        func isFilled(o: ThermometersObject) -> Bool {
            if case .filled = o {return true}
            return false
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let thermometerNodeName = "thermometer" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let (o1, o2) = (stateFrom[r, c], stateTo[r, c])
                guard String(describing: o1) != String(describing: o2) else {continue}
                let (isFilled1, isFilled2) = (isFilled(o: o1), isFilled(o: o2))
                if isFilled1 != isFilled2 { removeNode(withName: thermometerNodeName) }
                switch o1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                default:
                    break
                }
                if isFilled1 != isFilled2 && !isFilled2 { addThermometer(ch: stateFrom.game[p], filled: false, s: .normal, point: point, nodeName: thermometerNodeName) }
                switch o2 {
                case let .filled(s):
                    addThermometer(ch: stateFrom.game[p], filled: true, s: s, point: point, nodeName: thermometerNodeName)
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                default:
                    break
                }
            }
        }
    }
}
