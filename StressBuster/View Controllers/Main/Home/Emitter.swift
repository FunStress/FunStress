//
//  Emitter.swift
//  StressBuster
//
//  Created by Vamsikvkr on 5/13/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit

class Emitter {
    static func get(with image: UIImage) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterCells = generateEmitterCells(with: image)
        
        return emitter
    }
    
    static func generateEmitterCells(with image: UIImage) -> [CAEmitterCell] {
        var cells = [CAEmitterCell]()
        
        let cell = CAEmitterCell()
        cell.contents = image.cgImage
        cell.birthRate = 1
        cell.lifetime = 50
        cell.velocity = CGFloat(25)
        cell.emissionRange = (45 * (.pi/180))
        
        cell.scale = 0.5
        cell.scaleRange = 0.1
        
        cells.append(cell)
        
        return cells
    }
}
