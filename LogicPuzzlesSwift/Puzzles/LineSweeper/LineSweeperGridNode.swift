//
//  Grid.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

// http://stackoverflow.com/questions/33464925/draw-a-grid-with-spritekit

class LineSweeperGridNode : GridNode {
    convenience init(blockSize: CGFloat, rows: Int, cols: Int) {
        let texture = GridNode.gridTexture(blockSize: blockSize, rows: rows, cols: cols, verticalLinesRange: 0...cols, horizontalLinesRange: 0...rows)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    func linePosition(point: CGPoint) -> (Position, Int) {
        let row = Int(-point.y / blockSize)
        let col = Int(point.x / blockSize)
        let p = Position(row, col)
        let dx = point.x - (CGFloat(col) + 0.5) * blockSize
        let dy = -(point.y + (CGFloat(row) + 0.5) * blockSize)
        let dx2 = abs(dx), dy2 = abs(dy)
        return (p, -dy2...dy2 ~= dx ? dy > 0 ? 2 : 0 :
            -dx2...dx2 ~= dy ? dx > 0 ? 1 : 3 : 0);
    }
}
