//
//  MYMetalTriView.swift
//  meiyan
//
//  Created by kzw on 2020/5/15.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import MetalKit

class MYMetalTriView: MTKView {
    var commandQueue: MTLCommandQueue?
      var rps: MTLRenderPipelineState?
      var vertexBuffer: MTLBuffer?
      struct Vertex {
          var position: vector_float4
          var color: vector_float4
      }
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
//
      func createBuffer(){
        if device == nil{
            device = MTLCreateSystemDefaultDevice()
        }
          commandQueue = device?.makeCommandQueue()
//          let vertexData = [Vertex(position: [-0.5,-0.5,0.0,1.0], color: [1,0,0,1]),Vertex(position: [0.5,-0.5,0.0,1.0], color: [0,1,0,1]),Vertex(position: [0.0,0.5,0.0,1.0], color: [0,0,1,1])]
             let vertexData = [
                Vertex(position: [-0.5,-0.5,0.0,1.0], color: [1,0,0,1]),
                Vertex(position: [0.5,-0.5,0.0,1.0], color: [0,1,0,1]),
                Vertex(position: [-0.5,0.5,0.0,1.0], color: [0,0,1,1]),
                
                Vertex(position: [0.5,-0.5,0.0,1.0], color: [0,1,0,1]),
                Vertex(position: [-0.5,0.5,0.0,1.0], color: [0,0,1,1]),
                Vertex(position: [0.5,0.5,0.0,1.0], color: [0,0,1,1])
        ]
        vertexBuffer = device?.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.size * vertexData.count, options: [])
      }
      
      func registerShaders(){
          let library = device?.makeDefaultLibrary()!
          let vertex_func = library?.makeFunction(name: "vertex_func")
          let frag_func = library?.makeFunction(name: "fragment_func")
          let rpld = MTLRenderPipelineDescriptor()
          rpld.vertexFunction = vertex_func
          rpld.fragmentFunction = frag_func
          rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
          rps = try! device?.makeRenderPipelineState(descriptor: rpld)
      }
      
      override func draw() {//_ rect: CGRect
        super.draw() 
       // super.draw()  调用 super.draw() 崩溃。。。
          if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor{
              rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)
              let commandBuffer = commandQueue!.makeCommandBuffer()
              let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
              commandEncoder?.setRenderPipelineState(rps!)
              commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
              commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 2)
              commandEncoder?.endEncoding()
              commandBuffer?.present(drawable)
              commandBuffer?.commit()
          }
      }

}
