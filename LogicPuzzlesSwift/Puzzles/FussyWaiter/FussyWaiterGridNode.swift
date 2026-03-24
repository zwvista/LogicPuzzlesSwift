//
//  FussyWaiterGridNode.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

// http://stackoverflow.com/questions/33464925/draw-a-grid-with-spritekit

class FussyWaiterGridNode: GridNode {
    convenience init(blockSize: CGFloat, rows: Int, cols: Int) {
        let texture = GridNode.gridTexture(blockSize: blockSize, rows: rows, cols: cols, verticalLinesRange: 0...cols, horizontalLinesRange: 0...rows)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    func moveObject(p: Position, point: CGPoint) -> Character {
        let x = point.x - CGFloat(p.col) * blockSize
        let y = -point.y - CGFloat(p.row) * blockSize
        return x + y < blockSize ? "a" : "A"
    }
}
