//
//  MYMpegSWSPicViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/22.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
protocol MYRightShuoMingProtocol where Self:UIViewController{
    var message :String? { get set }

}
extension MYRightShuoMingProtocol{
     func gotoShuoMing(){
          if message?.count ?? 0 > 70 {
                let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "MYGPUShuoMingViewController") as! MYGPUShuoMingViewController
                vc.text = message
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let alertVC = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
                let OkAction = UIAlertAction.init(title:  "OK", style: .default) { (action) in
                }
                alertVC.addAction(OkAction)
                self.present(alertVC, animated: true, completion: {
                })
            }
        }
    
}
class MYMpegSWSPicViewController: UIViewController,MYRightShuoMingProtocol {

     var imgView: GPUImageView = GPUImageView.init(frame: CGRect.zero)
       var pictureInput :GPUImageRawDataInput?
       var filter:  (GPUImageOutput&GPUImageInput)?
       var srcPath :String?
        var message :String?
       override func viewDidLoad() {
           super.viewDidLoad()
           title = "FFmpeg读取第一帧（SWS）处理"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "说明", style: .done, target: self, action: #selector(rightAction))
           imgView.fillMode =  kGPUImageFillModePreserveAspectRatio //kGPUImageFillModePreserveAspectRatioAndFill//
           imgView.backgroundColor = .white
           self.view.addSubview(imgView)
           imgView.snp.makeConstraints { (make) in
               make.left.right.top.bottom.equalTo(0)
           }
        self.filter = GPUImageGrayscaleFilter.init()
        
//        let image = R.image.test2()!
//        self.pictureInput = MYToolUtils.image(toGLBytes: image)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
//            [weak self] in
//            self?.pictureInput?.addTarget(self?.filter)
//            self?.filter?.addTarget(self?.imgView)
//            // important
//            self?.filter?.useNextFrameForImageCapture()
//            self?.pictureInput?.processData()
//        }
        VideoUtils.swsPicture(srcPath!) {[weak self]  (rgb, size) in
            if self?.pictureInput == nil {
                DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + .milliseconds(2)) {
                  //  [weak self] in
                    self?.pictureInput = GPUImageRawDataInput.init(bytes: rgb, size: size, pixelFormat: GPUPixelFormatRGB)
                      self?.pictureInput?.addTarget(self?.filter)
                      self?.filter?.addTarget(self?.imgView)
                      self?.filter?.useNextFrameForImageCapture()
                       self?.pictureInput?.processData()
                }
            }
        }

       }
    @objc func rightAction(){
        gotoShuoMing()
    }
  

}
