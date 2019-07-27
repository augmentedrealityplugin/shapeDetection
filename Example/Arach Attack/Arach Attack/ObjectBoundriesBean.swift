//
//  File.swift
//  PlaneDetection
//
//  Created by Behram  Buhariwala on 6/11/19.
//  Copyright © 2019 Behram  Buhariwala. All rights reserved.
//

import Foundation

class ObjectBoundaries {
    var maxX: Float
    var maxY: Float
    var maxZ: Float
    var width: Float
    var height: Float
    init(maxX: Float, maxY: Float, maxZ: Float) {
        self.maxX = maxX
        self.maxY = maxY
        self.maxZ = maxZ
         self.height = 0.0
         self.width = 0.0
    }
    
    func getMaxX() -> Float {
        return self.maxX
    }
    
    func getMaxY() -> Float {
        return self.maxY
    }
    
    func getMaxZ() -> Float {
        return self.maxZ
    }
    func setHeight(height:Float){
        self.height = height
    }
    func getHeight() -> Float{
        return self.height
    }
    func setWidth(width:Float){
        self.width = width
    }
    func getWidth() -> Float{
        return self.width
    }
}
