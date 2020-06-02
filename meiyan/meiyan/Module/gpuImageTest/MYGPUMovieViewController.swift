//
//  MYGPUMovieViewController.swift
//  meiyan
//
//  Created by 康子文 on 2020/5/24.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYGPUMovieViewController: UIViewController {

    var videoCamera :GPUImageVideoCamera!
      var filter :(GPUImageOutput&GPUImageInput)!
      var movieWriter :GPUImageMovieWriter!
      var filterView :GPUImageView!
    var movieFile :GPUImageMovie!
    var mLabel :UILabel!
      override func viewDidLoad() {
          super.viewDidLoad()
              videoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .back)
              videoCamera.outputImageOrientation = UIApplication.shared.statusBarOrientation
              filter = GPUImageDissolveBlendFilter.init()
            let f = filter as! GPUImageDissolveBlendFilter
            f.mix = 0.5
          filterView = GPUImageView.init(frame: self.view.frame)
          self.view.addSubview(filterView)
        
        createView()
        
        let sampleURL = Bundle.main.url(forResource: "output", withExtension: "mp4")
        movieFile = GPUImageMovie.init(url: sampleURL)
        movieFile.runBenchmark = true
        //以实际速度播放
        movieFile.playAtActualSpeed = true
        
      let pathMovie = PTFileHandler.pathCaches + "/gpumovie.m4v"
      let movieUrl = URL.init(fileURLWithPath: pathMovie)
      PTFileHandler.deleteFileOrDirectory(path: pathMovie)
      movieWriter = GPUImageMovieWriter.init(movieURL: movieUrl, size: CGSize.init(width: 480, height: 640))
        
        let audioFromFile = false
        if audioFromFile{
            movieFile.addTarget(filter)
            videoCamera.addTarget(filter)
            movieWriter.shouldPassthroughAudio = true
            movieFile.audioEncodingTarget = movieWriter
            movieFile.enableSynchronizedEncoding(using: movieWriter)
        }else{
            videoCamera.addTarget(filter)
            movieFile.addTarget(filter)
            movieWriter.shouldPassthroughAudio = false
            videoCamera.audioEncodingTarget = movieWriter
            movieWriter.encodingLiveVideo = false
        }
        // 显示到界面
        filter.addTarget(filterView)
        filter.addTarget(movieWriter)
        videoCamera.startCapture()
        movieWriter.startRecording()
        movieFile.startProcessing()
        let dlink = CADisplayLink.init(target: self, selector: #selector(updateProgress))
        dlink.add(to: RunLoop.current, forMode: .common)
        dlink.isPaused = false
        weak var weakSelf = self
        movieWriter.completionBlock = {
            [weak self] in
            self?.filter.removeTarget(self?.movieWriter)
            self?.movieWriter.finishRecording()
            MYGPUWriteUtils.writeVideo(movieUrl: movieUrl, context: weakSelf)
        }
   
      }
    func createView(){
        mLabel = UILabel.init(frame: CGRect.init(x: (MYSeetings.S_WIDTH)/2.0, y: 88, width: 100, height: 30))
        mLabel.textColor = .red
        self.view.addSubview(mLabel)
        
    }
    @objc func updateProgress(){
        mLabel.text = "进度：\(movieFile.progress * 100)%"
        mLabel.sizeToFit()
    }

//      @objc func rightAction(_ btn:UIBarButtonItem){
//          let pathMovie = PTFileHandler.pathCaches + "/movieWrite.m4v"
//          let movieUrl = URL.init(fileURLWithPath: pathMovie)
//
//          lState = !lState
//          if lState{
//              btn.title = "结束"
//              PTFileHandler.deleteFileOrDirectory(path: pathMovie)
//              movieWriter = GPUImageMovieWriter.init(movieURL: movieUrl, size: CGSize.init(width: 480, height: 640))
//              movieWriter.encodingLiveVideo = true
//              filter.addTarget(movieWriter)
//              videoCamera.audioEncodingTarget = movieWriter
//              movieWriter.startRecording()
//          }else{
//              btn.title = "录制"
//              filter.removeTarget(movieWriter)
//              videoCamera.audioEncodingTarget = nil
//              movieWriter.finishRecording()
//              MYGPUWriteUtils.writeVideo(movieUrl: movieUrl, context: self)
//          }
//      }
}
