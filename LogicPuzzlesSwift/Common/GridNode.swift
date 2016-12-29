//
//  Grid.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

// http://stackoverflow.com/questions/33464925/draw-a-grid-with-spritekit

class GridNode : SKSpriteNode {
    var rows: Int!
    var cols: Int!
    var blockSize: CGFloat!
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func gridTexture(blockSize: CGFloat, rows: Int, cols: Int, verticalLinesRange: CountableClosedRange<Int>, horizontalLinesRange: CountableClosedRange<Int>) -> SKTexture {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols) * blockSize + 1.0, height: CGFloat(rows) * blockSize + 1.0)
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in verticalLinesRange {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: CGFloat(horizontalLinesRange.lowerBound) * blockSize + offset))
            bezierPath.addLine(to: CGPoint(x: x, y: CGFloat(horizontalLinesRange.upperBound) * blockSize + offset))
        }
        // Draw horizontal lines
        for i in horizontalLinesRange {
            let y = CGFloat(i) * blockSize + offset
            bezierPath.move(to: CGPoint(x: CGFloat(verticalLinesRange.lowerBound) * blockSize + offset, y: y))
            bezierPath.addLine(to: CGPoint(x: CGFloat(verticalLinesRange.upperBound) * blockSize + offset, y: y))
        }
        SKColor.gray.setStroke()
        bezierPath.lineWidth = 1.0
        bezierPath.stroke()
        context?.addPath(bezierPath.cgPath)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    
    func gridPosition(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = (CGFloat(p.col) + CGFloat(0.5)) * blockSize + offset
        let y = -((CGFloat(p.row) + CGFloat(0.5)) * blockSize + offset)
        return CGPoint(x: x, y: y)
    }
    
    func cellPosition(point: CGPoint) -> Position {
        let row = Int(-point.y / blockSize)
        let col = Int(point.x / blockSize)
        return Position(row, col)
    }
}
