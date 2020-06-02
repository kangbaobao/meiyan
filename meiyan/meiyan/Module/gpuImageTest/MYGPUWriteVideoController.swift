//
//  MYGPUWriteVideoController.swift
//  meiyan
//
//  Created by 康子文 on 2020/5/24.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import Photos
class MYGPUWriteVideoController: UIViewController {
    var videoCamera :GPUImageVideoCamera!
    var filter :(GPUImageOutput&GPUImageInput)!
    var movieWriter :GPUImageMovieWriter!
    var filterView :GPUImageView!
    var lState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .back)
        videoCamera.outputImageOrientation = UIApplication.shared.statusBarOrientation
        filter = GPUImageSepiaFilter.init()
        filterView = GPUImageView.init(frame: self.view.frame)
        self.view.addSubview(filterView)
       // self.view = filterView
        videoCamera.addTarget(filter)
        filter.addTarget(filterView)
        videoCamera.startCapture()
        NotificationCenter.default.addObserver(forName: UIApplication.didChangeStatusBarOrientationNotification, object: nil, queue: nil) {[weak self] (note) in
            self?.videoCamera.outputImageOrientation = UIApplication.shared.statusBarOrientation
        }
        createView()
    }
    
    func createView(){
      title = "演示录制效果"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "录制", style: .done, target: self, action: #selector(rightAction))
        let slider = UISlider.init(frame: CGRect.init(x: 20, y: MYSeetings.S_HEIGHT - 34 - 30, width: MYSeetings.S_WIDTH - 40, height: 30))
        self.view.addSubview(slider)

        slider.addTarget(self, action: #selector(slideVlaueChange(_:)), for: .valueChanged)
    }

    @objc func rightAction(_ btn:UIBarButtonItem){
        let pathMovie = PTFileHandler.pathCaches + "/movieWrite.m4v"
        let movieUrl = URL.init(fileURLWithPath: pathMovie)
        
        lState = !lState
        if lState{
            btn.title = "结束"
            PTFileHandler.deleteFileOrDirectory(path: pathMovie)
            movieWriter = GPUImageMovieWriter.init(movieURL: movieUrl, size: CGSize.init(width: 480, height: 640))
            movieWriter.encodingLiveVideo = true
            filter.addTarget(movieWriter)
            videoCamera.audioEncodingTarget = movieWriter
            movieWriter.startRecording()
        }else{
            btn.title = "录制"
            filter.removeTarget(movieWriter)
            videoCamera.audioEncodingTarget = nil
            movieWriter.finishRecording()
            MYGPUWriteUtils.writeVideo(movieUrl: movieUrl, context: self)
        }
    }

    
    @objc func slideVlaueChange(_ slider :UISlider){
        let f = filter as? GPUImageSepiaFilter
        f?.intensity = CGFloat(slider.value)
    }

}
