//
//  Grid.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

// http://stackoverflow.com/questions/33464925/draw-a-grid-with-spritekit

class LightenUpGridNode : SKSpriteNode {
    private(set) var rows: Int!
    private(set) var cols: Int!
    private(set) var blockSize: CGFloat!
    
    convenience init(blockSize: CGFloat, rows: Int, cols: Int) {
        let texture = LightenUpGridNode.gridTexture(blockSize: blockSize, rows: rows, cols: cols)
        self.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func gridTexture(blockSize: CGFloat, rows: Int, cols: Int) -> SKTexture {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols) * blockSize + 1.0, height: CGFloat(rows) * blockSize + 1.0)
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i) * blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        SKColor.white.setStroke()
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
