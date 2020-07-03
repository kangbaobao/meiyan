//
//  LBffmpegTool.h
//  meiyan
//
//  Created by kzw on 2020/6/19.
//  Copyright © 2020 康子文. All rights reserved.

/*
 /解码
 //    NSString *info_ns = [[LBffmpegTool sharedInstance] decoder:@"resource.bundle/sintel.mov" output_str:@"resource.bundle/test1.yuv"];
 //    NSLog(@"解码后的信息%@",info_ns);
 
     
      *在运行在真机的代码中必须把地址换成你自己的电脑IP（10.10.10.134）（不能再用local 本地了）
      *运行服务器的电脑和手机保证在同一WiFi下

     
     //推流
 //    [[LBffmpegTool sharedInstance] pushFlow:@"resource.bundle/war3end.mp4" output_str:@"rtmp://10.10.10.134:1992/liveApp/room"];
         //FFmpeg获取摄像头设备
     //    [[LBffmpegTool sharedInstance] showDevice];
     [[LBffmpegTool sharedInstance]getMovieDevice:self.view];
 
  替换过时方法 https://www.jianshu.com/p/6db48d604aff
 
 */
#import <Foundation/Foundation.h>
/*----------------解码必须导入-----------------*/
#import "avformat.h"
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
/*-------------------------------------------*/
/*----------------推流必须导入-----------------*/
//#include <libavformat/avformat.h>
#include <libavutil/mathematics.h>
#include <libavutil/time.h>
/*----------------系统摄像头必须导入-----------------*/

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
/*-------------------------------------------*/

/*----------------ffmpeg摄像头必须导入-----------------*/
#include <stdio.h>
#ifdef __cplusplus
extern "C"
{
#endif
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavdevice/avdevice.h>
    
#ifdef __cplusplus
};
#endif
/*---------------------------------------------------*/

//Refresh Event
#define SFM_REFRESH_EVENT  (SDL_USEREVENT + 1)

#define SFM_BREAK_EVENT  (SDL_USEREVENT + 2)

NS_ASSUME_NONNULL_BEGIN


@interface LBffmpegTool : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>


@property(nonatomic, strong) AVCaptureSession                *captureSession;
@property(nonatomic, strong) AVCaptureDevice                 *captureDevice;
@property(nonatomic, strong) AVCaptureDeviceInput            *captureDeviceInput;
@property(nonatomic, strong) AVCaptureVideoDataOutput        *captureVideoDataOutput;
@property(nonatomic, assign) CGSize                          videoSize;
@property(nonatomic, strong) AVCaptureConnection             *videoCaptureConnection;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer      *previewLayer;



+(instancetype)sharedInstance;

/*input_str  输入的文件路径
 *output_str 输出的文件路径
 *return 解码后的信息
 */
- (NSString *)decoder:(NSString *)input_str output_str:(NSString *)output_str;

/*
 *
 *input_str  输入的文件路径
 *output_str 输出的推流链接
 *
 */
- (void)pushFlow:(NSString *)input_str output_str:(NSString *)output_rtmpStr;

///iOS系统获取摄像头
- (void)getMovieDevice:(UIView *)view;

///ffmpeg系统获取摄像头
- (void)showDevice;


@end

NS_ASSUME_NONNULL_END
