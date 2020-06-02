//
//  MYGPUTiltShiftViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/18.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYGPUTiltShiftViewController: UIViewController {
    var sourcePicture :GPUImagePicture!
    var sepiaFilter:GPUImageTiltShiftFilter!
    override func viewDidLoad() {
        super.viewDidLoad()
        let primaryView = GPUImageView.init(frame: self.view.bounds)
        self.view.addSubview(primaryView)
        
        let inputImage = UIImage.init(named: "test1")
        sourcePicture = GPUImagePicture.init(image: inputImage!)
        sepiaFilter = GPUImageTiltShiftFilter.init()
        sepiaFilter.blurRadiusInPixels = 40.0
        sepiaFilter.forceProcessing(at: primaryView.sizeInPixels)
        sourcePicture.addTarget(sepiaFilter)
        sepiaFilter.addTarget(primaryView)
        sourcePicture.processImage()
        
        let size = GPUImageContext.maximumTextureSizeForThisDevice()
        let unit = GPUImageContext.maximumTextureUnitsForThisDevice()
        let vector = GPUImageContext.maximumVaryingVectorsForThisDevice()
        
        print("MYGPUTiltShiftViewController  size :\(size) unit :\(unit) vector :\(vector)")
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point  = touch?.location(in: self.view)
        let rate = point!.x / self.view.frame.size.height
        print("rate : \(rate)")
        
        sepiaFilter.topFocusLevel = rate - 0.1
        sepiaFilter.bottomFocusLevel = rate + 0.1
        sourcePicture.processImage()
    }

}
