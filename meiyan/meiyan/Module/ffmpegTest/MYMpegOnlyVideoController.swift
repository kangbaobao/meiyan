//
//  MYMpegOnlyVideoController.swift
//  meiyan
//
//  Created by kzw on 2020/5/25.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYMpegOnlyVideoController: UIViewController,MYRightShuoMingProtocol  {
    var imgView: GPUImageView = GPUImageView.init(frame: CGRect.zero)
    var pictureInput :GPUImageRawDataInput?
    var filter:  (GPUImageOutput&GPUImageInput)?
    var srcPath :String?
    var message :String?
    var stop = false
    var lastPro :Float = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
           title = "FFmpeg只播放视频"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "说明", style: .done, target: self, action: #selector(rightAction))
           imgView.fillMode =  kGPUImageFillModePreserveAspectRatio //kGPUImageFillModePreserveAspectRatioAndFill//
           imgView.backgroundColor = .white
           self.view.addSubview(imgView)
           imgView.snp.makeConstraints { (make) in
               make.left.right.top.bottom.equalTo(0)
           }
        self.filter = GPUImageGrayscaleFilter.init()
        DispatchQueue.global().async {
            [weak self] in
            VideoUtils.videoswsScaleplay(self?.srcPath! ?? "", block: {  (rgb, size) in
                if self?.pictureInput == nil {
                  self?.pictureInput = GPUImageRawDataInput.init(bytes: rgb, size: size, pixelFormat: GPUPixelFormatRGB)
                  self?.pictureInput?.addTarget(self?.filter)
                  self?.filter?.addTarget(self?.imgView)
                  self?.filter?.useNextFrameForImageCapture()
                   self?.pictureInput?.processData()
                }else{
                    self?.pictureInput?.updateData(fromBytes: rgb, size: size)
                    self?.pictureInput?.processData()
                }
            }) { (pro) -> Bool in
                //1% 秒更新一下进度
                if pro -  (self?.lastPro ?? 0) > 0.005{
                    DispatchQueue.main.async {
                        self?.title = "播放进度： \(Int(pro * 100))%"
                    }
                }
              return  self?.stop ?? true
            }
        }
        
        
//         let dst = PTFileHandler.pathCaches + "/mpegFirstaaq.ts"
//        //先删除文件，再创建
//        DispatchQueue.global().async {
//            [weak self] in
//            PTFileHandler.deleteFileOrDirectory(path: dst)
//            VideoUtils.ffmpegAddDrawText(self?.srcPath! ?? "", with: dst) { (rgb, size ) in
//                if self?.pictureInput == nil {
//                  self?.pictureInput = GPUImageRawDataInput.init(bytes: rgb, size: size, pixelFormat: GPUPixelFormatRGB)
//                  self?.pictureInput?.addTarget(self?.filter)
//                  self?.filter?.addTarget(self?.imgView)
//                  self?.filter?.useNextFrameForImageCapture()
//                   self?.pictureInput?.processData()
//                }else{
//                    self?.pictureInput?.updateData(fromBytes: rgb, size: size)
//                    self?.pictureInput?.processData()
//                }
//            }
//        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stop = true
    }

    @objc func rightAction(){
        gotoShuoMing()
    }
    deinit{
        print("\(self.classForCoder)");
    }
}
