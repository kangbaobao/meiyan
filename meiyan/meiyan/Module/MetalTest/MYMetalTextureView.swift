//
//  MYMetalTextureView.swift
//  meiyan
//
//  Created by kzw on 2020/6/2.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import MetalKit
struct  TextureVertex{
    //顶点坐标，分别是x、y、z、w
    var position :vector_float4
    //纹理坐标，x、y；
    var textureCoordinate:vector_float2
}
class MYMetalTextureView: MTKView {
    
    var commandQueue: MTLCommandQueue?
    var rps: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    var texture : MTLTexture?
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        createBuffer()
        registerShaders()
        setupTexture()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        createBuffer()
        registerShaders()
        setupTexture()
    }
    func createBuffer(){
      if device == nil{
          device = MTLCreateSystemDefaultDevice()
      }
        commandQueue = device?.makeCommandQueue()
        let vertexData = [
            TextureVertex.init(position: [ 0.5, -0.5, 0.0, 1.0 ], textureCoordinate: [ 1.0, 1.0]),
            TextureVertex.init(position: [ -0.5, -0.5, 0.0, 1.0 ], textureCoordinate: [ 0.0, 1.0]),
            TextureVertex.init(position: [ -0.5,  0.5, 0.0, 1.0], textureCoordinate: [  0.0, 0.0]),
            TextureVertex.init(position: [ 0.5, -0.5, 0.0, 1.0  ], textureCoordinate: [ 1.0, 1.0]),
            TextureVertex.init(position: [ -0.5,  0.5, 0.0, 1.0], textureCoordinate: [ 0.0, 0.0]),
            TextureVertex.init(position: [ 0.5,  0.5, 0.0, 1.0 ], textureCoordinate: [1.0, 0.0 ]),
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

    func setupTexture(){
        /*
         解决渲染出来的图片偏暗，即使是原图也会偏暗
         self.originalTexture = [loader newTextureWithData:imageData options:@{MTKTextureLoaderOptionSRGB:@(NO)} error:&err];

         
         快速获取texture
         let textureLoader = MTKTextureLoader(device: device!)
         let textureLoaderOptions : [MTKTextureLoader.Option : Any] =
           [.origin:
               MTKTextureLoader.Origin.bottomLeft]
         let url = Bundle.main.url(forResource: "test", withExtension: "png")
         self.texture = try! textureLoader.newTexture(URL: url!, options: textureLoaderOptions)
         **/
        // 这种方法可以用来处理RGBA视频流
        let image = R.image.test2()
        // 纹理描述符
        let textureDescriptor = MTLTextureDescriptor.init()
        textureDescriptor.pixelFormat = .rgba8Unorm
        let width = Int(image?.size.width ?? MYSeetings.S_WIDTH/2.0)
        let height = Int(image?.size.height ?? MYSeetings.S_HEIGHT/2.0)
        textureDescriptor.width = width
        textureDescriptor.height = height
        //    self.texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor]; // 创建纹理
        self.texture = self.device?.makeTexture(descriptor: textureDescriptor)
        //// 纹理上传的范围 3维
        let region = MTLRegion.init(origin: MTLOrigin.init(x: 0, y: 0, z: 0), size: MTLSize.init(width: width, height: height, depth: 1))
        var imageBytes = loadImage(image: image!)
        if imageBytes != nil {
            self.texture?.replace(region: region, mipmapLevel: 0, withBytes: imageBytes!, bytesPerRow: 4 * Int(image!.size.width))
            imageBytes?.deallocate()
            imageBytes = nil
        }
    }
    func loadImage(image :UIImage) -> UnsafeMutableRawPointer?{
         // 1获取图片的CGImageRef
        let spriteImage = image.cgImage
        // 2 读取图片的大小
        let width = spriteImage?.width ?? 0
        let height = spriteImage?.height ?? 0
        let spriteData = UnsafeMutableRawPointer.allocate(byteCount: width * height * 4, alignment: 0)
        let spriteContext = CGContext.init(data: spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow:  width*4, space: spriteImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        // 3在CGContextRef上绘图
        spriteContext?.draw(spriteImage!, in: CGRect.init(x: 0, y: 0, width: width, height: height))
        //自动内存管理了不需要手动释放
     //   CGContextRelease(spriteContext!);

        return spriteData
    }
    
    
    
    override func draw() {
         super.draw()
           if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor{
               rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)
               let commandBuffer = commandQueue!.makeCommandBuffer()
               let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
//            commandEncoder?.setViewport(MTLViewport.init(originX: 0, originY: 0, width: Double(MYSeetings.S_WIDTH), height: Double(MYSeetings.S_HEIGHT), znear: -1.0, zfar: 1.0))
               commandEncoder?.setRenderPipelineState(rps!)
               commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
             commandEncoder?.setFragmentTexture(self.texture, index: 0)
             //  commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 2)
            /*
             renderEncoder.setVertexBytes(&uniforms,
                                          length: MemoryLayout<Uniforms>.stride, index: 1)
             **/
            commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
               commandEncoder?.endEncoding()
               commandBuffer?.present(drawable)
               commandBuffer?.commit()
           }
    }
    
}
