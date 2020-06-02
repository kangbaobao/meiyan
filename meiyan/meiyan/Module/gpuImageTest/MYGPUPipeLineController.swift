//
//  MYGPUPipeLineController.swift
//  meiyan
//
//  Created by kzw on 2020/5/27.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYGPUPipeLineController: UIViewController {
    var imageView: GPUImageView = GPUImageView.init(frame: CGRect.zero)
    var picture :GPUImagePicture = GPUImagePicture.init(image: MaYuImage)
    var pipeline :GPUImageFilterPipeline!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.fillMode =  kGPUImageFillModePreserveAspectRatio //kGPUImageFillModePreserveAspectRatioAndFill//
         imageView.backgroundColor = .black
         self.view.addSubview(imageView)
         imageView.snp.makeConstraints { (make) in
             make.left.right.top.bottom.equalTo(0)
         }
        // 使用 GPUImageFilterPipeline 添加组合滤镜
        let filter1 = GPUImageRGBFilter.init()
        let filter2 = GPUImageToonFilter.init()
        let arr = [filter1,filter2]
        pipeline = GPUImageFilterPipeline.init(orderedFilters: arr, input: picture, output: imageView)
        // 处理图片
        picture.processImage()
//          [filter1 useNextFrameForImageCapture]; // 这个filter 可以是filter1 filter2等
//
//            // 输出处理后的图片
//            _outputImage = [_pipeline currentFilteredFrame];
//
    }
    

}
