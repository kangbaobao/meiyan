//
//  MYMatrix.swift
//  meiyan
//
//  Created by kzw on 2020/6/22.
//  Copyright © 2020 康子文. All rights reserved.
//

import Foundation
struct Matrix {
       var m: [Float]
       init() {
           m = [1,0,0,0,
                0,1,0,0,
                0,0,1,0,
                0,0,0,1]
       }
       
       func translartionMatrix(_ matrix: Matrix, _ position: SIMD3<Float>) -> Matrix{
       var matrix = matrix
           matrix.m[12] = position.x
           matrix.m[13] = position.y
           matrix.m[14] = position.z
           return matrix
       }
       
       func scalingMatrix(_ matrix:Matrix, _ scale: Float) ->Matrix{
           var matrix = matrix
           matrix.m[0] = scale
           matrix.m[5] = scale
           matrix.m[10] = scale
           matrix.m[15] = 1.0
           return matrix
       }
       
       func rotationMatrix(_ matrix: Matrix, _ rot: SIMD3<Float>) -> Matrix {
           var matrix = matrix
           matrix.m[0] = cos(rot.y) * cos(rot.z)
           matrix.m[4] = cos(rot.z) * sin(rot.x) * sin(rot.y) - cos(rot.x) * sin(rot.z)
           matrix.m[8] = cos(rot.x) * cos(rot.z) * sin(rot.y) + sin(rot.x) * sin(rot.z)
           matrix.m[1] = cos(rot.y) * sin(rot.z)
           matrix.m[5] = cos(rot.x) * cos(rot.z) + sin(rot.x) * sin(rot.y) * sin(rot.z)
           matrix.m[9] = -cos(rot.z) * sin(rot.x) + cos(rot.x) * sin(rot.y) * sin(rot.z)
           matrix.m[2] = -sin(rot.y)
           matrix.m[6] = cos(rot.y) * sin(rot.x)
           matrix.m[10] = cos(rot.x) * cos(rot.y)
           matrix.m[15] = 1.0
           return matrix
       }

       func modelMatrix(_ matrix:Matrix) ->Matrix{
           var matrix = matrix
           matrix = rotationMatrix(matrix, SIMD3<Float>(0.0,0.0,0.1))
           matrix = scalingMatrix(matrix, 0.25)
           matrix = translartionMatrix(matrix, SIMD3<Float>(0.0,0.5,0.0))
           return matrix
       }
   }
