//
//  MYMpegFirstViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/21.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
/*
 self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
 [self.view addSubview:self.filterView];
 
 // 1. UIImage -> CGImage -> CFDataRef -> UInt8 * data
 UIImage *image = [UIImage imageNamed:@"img1.jpg"];
 CGImageRef newImageSource = [image CGImage];
 CFDataRef dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
 GLubyte* imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
 
 // 2. UInt8 * data -> GPUImageRawDataInput
 self.rawDataInput = [[GPUImageRawDataInput alloc] initWithBytes:imageData size:image.size pixelFormat:GPUPixelFormatRGBA];
 self.filter = [[GPUImageBrightnessFilter alloc] init];
 self.filter.brightness = 0.1;
 

 [self.rawDataInput addTarget:self.filter];
 // 3. 输出到 GPUImageView
 [self.filter addTarget:self.filterView];
 **/

/*
 jmid_renderyuv = env->GetMethodID(jlz, "onCallRenderYUV", "(II[B[B[B)V");

 void WlCallJava::onCallRenderYUV(int width, int height, uint8_t *fy, uint8_t *fu, uint8_t *fv) {

     JNIEnv *jniEnv;
     if(javaVM->AttachCurrentThread(&jniEnv, 0) != JNI_OK)
     {
         if(LOG_DEBUG)
         {
             LOGE("call onCallComplete worng");
         }
         return;
     }

     jbyteArray y = jniEnv->NewByteArray(width * height);
     jniEnv->SetByteArrayRegion(y, 0, width * height, reinterpret_cast<const jbyte *>(fy));

     jbyteArray u = jniEnv->NewByteArray(width * height / 4);
     jniEnv->SetByteArrayRegion(u, 0, width * height / 4, reinterpret_cast<const jbyte *>(fu));

     jbyteArray v = jniEnv->NewByteArray(width * height / 4);
     jniEnv->SetByteArrayRegion(v, 0, width * height / 4, reinterpret_cast<const jbyte *>(fv));

     jniEnv->CallVoidMethod(jobj, jmid_renderyuv, width, height, y, u, v);

     jniEnv->DeleteLocalRef(y);
     jniEnv->DeleteLocalRef(u);
     jniEnv->DeleteLocalRef(v);

     javaVM->DetachCurrentThread();
 }
 
 if (avFrame->format == AV_PIX_FMT_YUV420P){
     //直接渲染
     LOGD("YUV420P");
     video->callJava->onCallRenderYUV(
             CHILD_THREAD,
             video->pVCodecCtx->width,
             video->pVCodecCtx->height,
             avFrame->data[0],
             avFrame->data[1],
             avFrame->data[2]);
 } else {
     //转成YUV420P
     AVFrame *pFrameYUV420P = av_frame_alloc();
     int num = av_image_get_buffer_size(AV_PIX_FMT_YUV420P,video->pVCodecCtx->width,video->pVCodecCtx->height,1);
     uint8_t *buffer = (uint8_t *)(av_malloc(num * sizeof(uint8_t)));
     av_image_fill_arrays(
             pFrameYUV420P->data,
             pFrameYUV420P->linesize,
             buffer,
             AV_PIX_FMT_YUV420P,
             video->pVCodecCtx->width,
             video->pVCodecCtx->height,
             1);
     SwsContext *sws_ctx = sws_getContext(
             video->pVCodecCtx->width,
             video->pVCodecCtx->height,
             video->pVCodecCtx->pix_fmt,
             video->pVCodecCtx->width,
             video->pVCodecCtx->height,
             AV_PIX_FMT_YUV420P,
             SWS_BICUBIC,
             NULL,NULL,NULL
             );

     if (!sws_ctx){
         av_frame_free(&pFrameYUV420P);
         av_free(pFrameYUV420P);
         av_free(buffer);
         continue;
     }

     sws_scale(
             sws_ctx,
             avFrame->data,
             avFrame->linesize,
             0,
             avFrame->height,
             pFrameYUV420P->data,
             pFrameYUV420P->linesize);//这里得到YUV数据
     LOGD("NO_YUV420P");
     //渲染
     video->callJava->onCallRenderYUV(
             CHILD_THREAD,
             video->pVCodecCtx->width,
             video->pVCodecCtx->height,
             pFrameYUV420P->data[0],
             pFrameYUV420P->data[1],
             pFrameYUV420P->data[2]);

     av_frame_free(&pFrameYUV420P);
     av_free(pFrameYUV420P);
     av_free(buffer);
     sws_freeContext(sws_ctx);
 }
 */
class MYMpegFirstViewController: UIViewController,MYRightShuoMingProtocol {
    var message: String?
    var imgView: GPUImageView = GPUImageView.init(frame: CGRect.zero)
    var pictureInput :GPUImagePicture!//= GPUImagePicture.init(image: MaYuImage)
    var filter: (GPUImageOutput&GPUImageInput)!
    var srcPath :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FFmpeg读取第一帧（GrayscaleFilter）处理"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "说明", style: .done, target: self, action: #selector(rightAction))
        imgView.fillMode =  kGPUImageFillModePreserveAspectRatio //kGPUImageFillModePreserveAspectRatioAndFill//
        imgView.backgroundColor = .black
        self.view.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        filter = GPUImageGrayscaleFilter.init()
        
        let dst = PTFileHandler.pathCaches + "/mpegFirst.jpg"
        //先删除文件，再创建
        PTFileHandler.deleteFileOrDirectory(path: dst)
        VideoUtils.ffmpegGetPicture(srcPath!, with: dst)
        let img = UIImage.init(contentsOfFile: dst)
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + .milliseconds(10)) {
            [weak self] in
            self?.pictureInput = GPUImagePicture.init(image: img)
            self?.pictureInput.addTarget( self?.filter)
            self?.filter.addTarget( self?.imgView)
            self?.pictureInput.useNextFrameForImageCapture()
            self?.pictureInput.processImage()
        }
    }
    
    @objc func rightAction(){
        gotoShuoMing()
    }

}
