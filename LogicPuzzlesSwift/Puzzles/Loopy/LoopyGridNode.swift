//
//  LoopyGridNode.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

// http://stackoverflow.com/questions/33464925/draw-a-grid-with-spritekit

class LoopyGridNode: GridNode {
    convenience init(blockSize: CGFloat, rows: Int, cols: Int) {
        let texture = GridNode.gridTexture(blockSize: blockSize, rows: rows, cols: cols, verticalLinesRange: 0...cols, horizontalLinesRange: 0...rows)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    func dotPosition(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = CGFloat(p.col) * blockSize + offset
        let y = -(CGFloat(p.row) * blockSize + offset)
        return CGPoint(x: x, y: y)
    }
    
    func linePosition(point: CGPoint) -> (Bool, Position, Int) {
        let offset: CGFloat = 10
        let r = Int((-point.y + offset) / blockSize)
        let c = Int((point.x + offset) / blockSize)
        let p = Position(r, c)
        return -offset...offset ~= -point.y - CGFloat(r) * blockSize ? (true, p, 1) :
            -offset...offset ~= point.x - CGFloat(c) * blockSize ? (true, p, 2) :
            (false, p, 1)
    }
}
