//
//  MYMetalModelView.swift
//  meiyan
//
//  Created by kzw on 2020/6/22.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import MetalKit
class MYMetalModelView: MTKView {
    struct Vertex {
        var position: vector_float4
        var color: vector_float4
    }
//    struct Uniforms{
//        var modelMatrix: matrix_float4x4
//    }
    
    var commandQueue: MTLCommandQueue?
    var rps: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    private var modelMatrix : Matrix!
    private var lastTime = Date.init().timeIntervalSince1970
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        createBuffer()
        registerShaders()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        createBuffer()
        registerShaders()
    }

    func createBuffer(){
        if device == nil{
            device = MTLCreateSystemDefaultDevice()
        }
        commandQueue = device?.makeCommandQueue()
        let vertex_data = [
           Vertex(position: [-1.0,-1.0,0.0,1.0], color: [1,0,0,1]),
            Vertex(position: [1.0,-1.0,0.0,1.0], color: [0,1,0,1]),
            Vertex(position: [0.0,1.0,0.0,1.0], color: [0,0,1,1])
        ]
        vertexBuffer = device?.makeBuffer(bytes: vertex_data, length: MemoryLayout<Vertex>.size * vertex_data.count , options: [])
        
        modelMatrix = Matrix().modelMatrix(Matrix())

        uniformBuffer = device?.makeBuffer(bytes: modelMatrix.m, length: MemoryLayout<Float>.size * modelMatrix.m.count, options: [])
//        uniformBuffer = device?.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
//        let bufferPointer = uniformBuffer.contents()
//        modelMatrix = Matrix().modelMatrix(Matrix())
//        memcpy(bufferPointer, modelMatrix.m, MemoryLayout<Float>.size * 16)
    }
    func registerShaders(){
        let library = device?.makeDefaultLibrary()
        let vert = library?.makeFunction(name: "modelVertext_func")
        let frag = library?.makeFunction(name: "modelFragment_func")
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vert
        rpld.fragmentFunction = frag
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        do{
            
            try rps = device?.makeRenderPipelineState(descriptor: rpld)
        }catch{
            print("makeRenderPipelineState fail...")
        }
    }
    override func draw() {
        //  super.draw() 一定要调用 否则出错。。。。
        super.draw()
        if let rpd = self.currentRenderPassDescriptor,let drawable = self.currentDrawable{//
            
            let bufferPointer = uniformBuffer.contents()
            //let z = Double.pi * arc
            let z = Date.init().timeIntervalSince1970 - lastTime
            modelMatrix = Matrix().rotationMatrix(modelMatrix,  SIMD3<Float>(0.0,0.0, Float(Double.pi * z)))
            memcpy(bufferPointer, modelMatrix.m, MemoryLayout<Float>.size * 16)
            
            rpd.colorAttachments[0].clearColor = MTLClearColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            let commandBuffer = commandQueue?.makeCommandBuffer()//device!.makeCommandQueue()?.makeCommandBuffer()
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
            commandEncoder?.setRenderPipelineState(rps!)
            commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            commandEncoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }

}
