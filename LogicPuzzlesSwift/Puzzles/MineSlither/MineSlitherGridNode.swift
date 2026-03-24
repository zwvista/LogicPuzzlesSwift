//
//  MineSlitherGridNode.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

// http://stackoverflow.com/questions/33464925/draw-a-grid-with-spritekit

class MineSlitherGridNode: GridNode {
    convenience init(blockSize: CGFloat, rows: Int, cols: Int) {
        let texture = GridNode.gridTexture(blockSize: blockSize, rows: rows, cols: cols, verticalLinesRange: 0...cols, horizontalLinesRange: 0...rows)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    func cornerPosition(point: CGPoint) -> (Bool, Position) {
        let offset = 20.0
        let row = Int((-point.y + offset) / blockSize)
        let col = Int((point.x + offset) / blockSize)
        let x = point.x - CGFloat(col) * blockSize
        let y = -point.y - CGFloat(row) * blockSize
        let isCorner = abs(x) < offset && abs(y) < offset
        return (isCorner, Position(row, col))
    }
}
