//
//  MYGPUSampleCameraViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/15.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYGPUSampleCameraViewController: UIViewController {

    @IBOutlet weak var mGPUImg: GPUImageView!
    var mGPUVideoCamera:GPUImageVideoCamera!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "调用摄像头"
        self.mGPUVideoCamera = GPUImageVideoCamera.init(sessionPreset:AVCaptureSession.Preset.vga640x480.rawValue , cameraPosition: .back)
        //设置屏幕方向
        self.mGPUVideoCamera.outputImageOrientation = .portrait
        mGPUImg.fillMode = kGPUImageFillModePreserveAspectRatio//kGPUImageFillModeStretch
        let filter = GPUImageGrayscaleFilter.init()
        mGPUVideoCamera.addTarget(filter)
        filter.addTarget(mGPUImg)
        mGPUVideoCamera.startCapture()
       
//        DispatchQueue.main.async {
//            [weak self] in
//            self?.mGPUVideoCamera.startCapture()
//
//        }
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        //            [mGPUImg setInputRotation:kGPUImageRotateLeft atIndex:0];

        
    }
    
    @objc func deviceOrientationDidChange(){
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)
        if let o = orientation{
            mGPUVideoCamera.outputImageOrientation = o
        }
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }


}
