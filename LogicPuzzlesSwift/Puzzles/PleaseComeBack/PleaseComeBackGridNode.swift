//
//  PleaseComeBackGridNode.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

// http://stackoverflow.com/questions/33464925/draw-a-grid-with-spritekit

class PleaseComeBackGridNode: GridNode {
    convenience init(blockSize: CGFloat, rows: Int, cols: Int) {
        let texture = GridNode.gridTexture(blockSize: blockSize, rows: rows, cols: cols, verticalLinesRange: 0...cols, horizontalLinesRange: 0...rows)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }

    func linePosition(point: CGPoint) -> (Position, Int) {
        let r = Int(-point.y / blockSize)
        let c = Int(point.x / blockSize)
        let p = Position(r, c)
        let dx = point.x - (CGFloat(c) + 0.5) * blockSize
        let dy = -(point.y + (CGFloat(r) + 0.5) * blockSize)
        let dx2 = abs(dx), dy2 = abs(dy)
        return (p, dx2 <= dy2 ? dy > 0 ? 2 : 0 :
            dy2 <= dx2 ? dx > 0 ? 1 : 3 : 0)
    }
}
