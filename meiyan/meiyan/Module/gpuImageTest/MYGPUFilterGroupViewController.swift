//
//  MYGPUFilterGroupViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/18.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYGPUFilterGroupViewController: UIViewController {

   // var imgView :GPUImageView!
    var iconImgView :UIImageView!
    var inputImg :UIImage!
    var outputImg :UIImage!
    var picture :GPUImagePicture!
    var filterGroup :GPUImageFilterGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputImg = UIImage.init(named: "test1")!
        picture = GPUImagePicture.init(image: inputImg, smoothlyScaleOutput: true)
        // 初始化 imageView
//        imgView = GPUImageView.init(frame: self.view.bounds)
//        self.view.addSubview(imgView)
        iconImgView = UIImageView.init(frame: self.view.bounds)
        self.view.addSubview(iconImgView)
        
        // 初始化 filterGroup
        filterGroup = GPUImageFilterGroup.init()
        picture.addTarget(filterGroup)
        
        // 添加 filter
        /**
         原理：
         1. filterGroup(addFilter) 滤镜组添加每个滤镜
         2. 按添加顺序（可自行调整）前一个filter(addTarget) 添加后一个filter
         3. filterGroup.initialFilters = @[第一个filter]];
         4. filterGroup.terminalFilter = 最后一个filter;
         */
        let filter1 = GPUImageRGBFilter.init()
        filter1.red = 1
//        filter1.green  = 0.0
//        filter1.blue = 0.5
        
        let filter2 = GPUImageToonFilter.init()
        let filter3 = GPUImageColorInvertFilter.init()
        let filter4 = GPUImageSepiaFilter.init()
        self.addGPUFilter(filter: filter1)
        self.addGPUFilter(filter: filter2)
        self.addGPUFilter(filter: filter3)
        self.addGPUFilter(filter: filter4)
        
        // 处理图片
        picture.processImage()
        filterGroup.useNextFrameForImageCapture()
        self.iconImgView.image = filterGroup.imageFromCurrentFramebuffer()
    }
    
    func addGPUFilter(filter : GPUImageOutput&GPUImageInput){
        filterGroup.addFilter(filter)
        let newTerminalFilter = filter
        let count = filterGroup.filterCount()
        if count == 1{
            filterGroup.initialFilters = [newTerminalFilter]
            filterGroup.terminalFilter = newTerminalFilter
        }else{
            let terminalFilter = filterGroup.terminalFilter
            let initialFilters = filterGroup.initialFilters
            
            terminalFilter?.addTarget(newTerminalFilter)
            
            filterGroup.initialFilters = [initialFilters!.first ]
            filterGroup.terminalFilter = newTerminalFilter
        }
    }

}
