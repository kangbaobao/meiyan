//
//  MYMetalTextureVideoView.swift
//  meiyan
//
//  Created by kzw on 2020/6/23.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import MetalKit
class MYMetalTextureVideoView: MTKView {
      var commandQueue: MTLCommandQueue?
        var rps: MTLRenderPipelineState?
        var vertexBuffer: MTLBuffer?
        var texture : MTLTexture?
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
            let vertexData = [
                TextureVertex.init(position: [ -1.0, -1.0, 0.0, 1.0 ], textureCoordinate: [ 1.0, 0.0]),
                TextureVertex.init(position: [ 1.0, -1.0, 0.0, 1.0 ], textureCoordinate: [ 1.0, 1.0] ),
                TextureVertex.init(position: [ -1.0,  1.0, 0.0, 1.0], textureCoordinate: [0.0, 0.0 ]),
                TextureVertex.init(position: [ 1.0,  1.0, 0.0, 1.0 ], textureCoordinate: [ 0.0, 1.0] ),
            ]
            //⚠️⚠️⚠️ 使用stride 不是size
            vertexBuffer = device?.makeBuffer(bytes: vertexData, length: MemoryLayout<TextureVertex>.stride * vertexData.count, options: [])//.storageModeShared
        }
        func registerShaders(){
            let library = device?.makeDefaultLibrary()!
            let vertex_func = library?.makeFunction(name: "textureVertext_func")
            let frag_func = library?.makeFunction(name: "textureFragment_func")
            let rpld = MTLRenderPipelineDescriptor()
            rpld.vertexFunction = vertex_func
            rpld.fragmentFunction = frag_func
            rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
            rps = try! device?.makeRenderPipelineState(descriptor: rpld)
        }
    //rgba
    func setupTexture(imageBytes :UnsafeMutableRawPointer?,size :CGSize){
        //设置裁剪模式 ⚠️⚠️⚠️ 宽高反过来设置
        self.drawableSize = CGSize(width: size.height , height:size.width)
            // 这种方法可以用来处理RGBA视频流
            // 纹理描述符
            let textureDescriptor = MTLTextureDescriptor.init()
            textureDescriptor.pixelFormat = .rgba8Unorm//.rgba8Unorm
            let width = size.width
            let height = size.height
            textureDescriptor.width = Int(width)
            textureDescriptor.height = Int(height)
            //textureDescriptor.con
            self.texture = self.device?.makeTexture(descriptor: textureDescriptor)
            //// 纹理上传的范围 3维
        let region = MTLRegion.init(origin: MTLOrigin.init(x: 0, y: 0, z: 0), size: MTLSize.init(width: Int(width), height: Int(height), depth: 1))
            if imageBytes != nil {
                self.texture?.replace(region: region, mipmapLevel: 0, withBytes: imageBytes!, bytesPerRow: 4 * Int(width))
              //  imageBytes?.deallocate()
            }
        
        if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor,let t = texture{
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)
            let commandBuffer = commandQueue!.makeCommandBuffer()
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
            commandEncoder?.setRenderPipelineState(rps!)
            commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
          commandEncoder?.setFragmentTexture(t, index: 0)
         //clockwise 顺时针方向的
         commandEncoder?.setFrontFacing(.counterClockwise)
         commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            commandEncoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
        }
        
        override func draw() {
             super.draw()

        }
}
