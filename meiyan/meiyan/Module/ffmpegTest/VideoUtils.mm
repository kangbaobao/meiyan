//
//  VideoUtils.m
//  ffmpegTest
//
//  Created by 康子文 on 2020/3/21.
//  Copyright © 2020 e-lead. All rights reserved.
//

#import "VideoUtils.h"
#include "mpegUtils.hpp"
#include "MYMpegDraw.hpp"
//#import <AVFoundation/AVFoundation.h>

//#import <GPUimag>
//#import <GPUImage/GPUImage.h>
static RGBBlock golbalRGBBlock = nil;
static VideoHandlerBlock globalvideoBlock = nil;
static RGBABlock golbalRGBABlock = nil;
static CVMetalTextureCacheRef textureCache;
static METALTextureBlock textureBlock = nil;
@implementation VideoUtils
+(NSString *)ffmpegConifg{
    const char * con = avcodec_configuration();
    NSLog(@"ffmpegConifg : %s",con);
    
    return [[NSString alloc] initWithCString:con encoding:NSUTF8StringEncoding];
}

+(void)ffmpegGetPicture:(NSString *)src with:(NSString* )dst{
//   NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"MOV"];
////    NSString *path = @"http://mena-epartner.hikvision.com/INTELb2bPro//8313/file/2020-03-20/42a720db4dc60618a7038d9586a6102b.mp4";
//    NSLog(@"path : %@",path);
//    //OpenInput(path.UTF8String);
//    //获取Caches路径
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *outpath = [paths objectAtIndex:0];
//    NSLog(@"path：%@", outpath);
//    NSString *outfile = [NSString stringWithFormat:@"%@/test.jpeg",outpath];
    puctureMain(src.UTF8String,dst.UTF8String);
}
+(NSString *)ffmpegToMP4:(NSString *)src with:(NSString* )dst{
    toMP4Main(src.UTF8String,dst.UTF8String);
   std::string p = achieve_header(dst.UTF8String);
    NSString *str = [[NSString alloc] initWithCString:p.c_str() encoding:NSUTF8StringEncoding];
    return str;
}
+(void)ffmpegAddDrawText:(NSString *)src with:(NSString* )dst block:(RGBBlock)rgbBlock{
    golbalRGBBlock = rgbBlock;
    MYMpegDraw draw;
    draw.drawTextDain(src.UTF8String,dst.UTF8String,swsData);

}
+(void) swsPicture:(NSString *)src block:(RGBBlock)rgbBlock{
    golbalRGBBlock = rgbBlock;
    puctureswsScale(src.UTF8String, swsData);
}
// 视频解码
+(void)videoswsScaleplay:(NSString *)src block:(RGBBlock)rgbBlock handler:(VideoHandlerBlock)hBlock{
    golbalRGBBlock = rgbBlock;
    globalvideoBlock = hBlock;
    videoswsScaleplay(src.UTF8String, swsData,videoData);
}
// 摄像头解码视频
+(void)creamswsScaleplay:(RGBBlock)rgbBlock handler:(VideoHandlerBlock)hBlock{
    golbalRGBBlock = rgbBlock;
    globalvideoBlock = hBlock;
    cermaswsScaleplay(swsData, videoData);
}
+(void)creamswsRGBAScaleplay:(RGBABlock)rgbaBlock handler:(VideoHandlerBlock)hBlock{
    golbalRGBABlock = rgbaBlock;
    globalvideoBlock = hBlock;
    cermaswsRGBAScaleplay(swsRGBAData, videoData);
}

+(void)videoswsHWRGBAScaleplay:(NSString *)src metal:(MTKView * )kView block:(METALTextureBlock)mBlock handler:(VideoHandlerBlock)hBlock {
    CVMetalTextureCacheCreate(NULL, NULL,kView.device, NULL, &textureCache); // TextureCache的创建
    textureBlock = mBlock;
    globalvideoBlock = hBlock;
    videoswsHWRGBAScaleplay(src.UTF8String, swsHWRGBAData, videoData);
    /*
     CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)videoFrame->data[3];
     CMTime presentationTimeStamp = kCMTimeInvalid;
     int64_t originPTS = videoFrame->pts;
     int64_t newPTS    = originPTS - baseTime;
     presentationTimeStamp = CMTimeMakeWithSeconds(current_timestamp + newPTS * av_q2d(videoStream->time_base) , fps);
     CMSampleBufferRef sampleBufferRef = [self convertCVImageBufferRefToCMSampleBufferRef:(CVPixelBufferRef)pixelBuffer
                                                                withPresentationTimeStamp:presentationTimeStamp];
     
     CFRelease(sampleBufferRef);

     **/
}
//
//接受rgb参数
+(void)dataRGB:(int)width height:(int)height r:(uint8_t *)r linsize:(int)linesize {
    NSLog(@"dataRGB...");
    CGSize size = CGSizeMake(width, height);
    if (golbalRGBBlock != nil) {
        golbalRGBBlock(r,size);
    }
}
//rgba
+(void)dataRGBA:(int)width height:(int)height r:(uint8_t *)r linsize:(int)linesize {
    NSLog(@"dataRGB...");
    CGSize size = CGSizeMake(width, height);
    if (golbalRGBABlock != nil) {
        golbalRGBABlock(r,size);
    }
}
//硬件解码处理
+(void)dataHW:(int)width height:(int)height r:(uint8_t *)r  {
    NSLog(@"硬件解码处理...");
  
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)r;
    id<MTLTexture> textureY = nil;
    id<MTLTexture> textureUV = nil;
    // textureY 设置
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        MTLPixelFormat pixelFormat = MTLPixelFormatR8Unorm; // 这里的颜色格式不是RGBA
        CVMetalTextureRef texture = NULL; // CoreVideo的Metal纹理
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, textureCache, pixelBuffer, NULL, pixelFormat, width, height, 0, &texture);
        if(status == kCVReturnSuccess) {
            textureY = CVMetalTextureGetTexture(texture); // 转成Metal用的纹理
            CFRelease(texture);
        }
    }
    // textureUV 设置
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
        MTLPixelFormat pixelFormat = MTLPixelFormatRG8Unorm; // 2-8bit的格式
        
        CVMetalTextureRef texture = NULL; // CoreVideo的Metal纹理
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, textureCache, pixelBuffer, NULL, pixelFormat, width, height, 1, &texture);
        if(status == kCVReturnSuccess)
        {
            textureUV = CVMetalTextureGetTexture(texture); // 转成Metal用的纹理
            CFRelease(texture);
        }
    }
    if(textureY != nil && textureUV != nil){
        if (textureBlock != nil) {
            textureBlock(textureY,textureUV);
        }
    }
    CFRelease(pixelBuffer); // 记得释放
}

CVPixelBufferRef CreatePixelBuffer(size_t width, size_t height)
{
    CVPixelBufferRef pixel_buffer;
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    // our empty IOSurface properties dictionary
    empty = CFDictionaryCreate(kCFAllocatorDefault, nullptr, nullptr, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);

    CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs, &pixel_buffer);
    if (err) {
        printf("Error at CVPixelBufferCreate");
      //  LOG(LS_ERROR) << "FBO size " << width << "x" << height << ", Error at CVPixelBufferCreate " << err;
    }
    CFRelease(attrs);
    CFRelease(empty);
    return pixel_buffer;
}

//原文链接：https://blog.csdn.net/momo0853/java/article/details/80692860

+(bool) videData:(float)pro{
    if (globalvideoBlock==nil){
        return true;
    }
    return globalvideoBlock(pro);
}
//回调
static void swsData(int width, int height, uint8_t *r, int linesize){
    [VideoUtils dataRGB:width height:height r:r linsize:linesize];
}
//回调
static void swsRGBAData(int width, int height, uint8_t *r, int linesize){
    [VideoUtils dataRGBA:width height:height r:r linsize:linesize];
}
//回调2 返回值用来标记是否停止解码 ，参数是进度百分比
static void videoData(void *data){
    struct VIDEOPARM *vs = (struct VIDEOPARM *)data;
    bool zd = [VideoUtils videData:vs->pro];
    vs->zhongduan = zd;
    NSLog(@"videoData : %f \n",vs->pro);
}
//硬件解码回调
static void swsHWRGBAData(int width, int height, uint8_t *r, int linesize){
    [VideoUtils dataHW:width height:height r:r];
}

/*
 //硬件解码
 https://github.com/XiaoDongXie1024/XDXVideoDecoder/blob/master/OC/XDXVideoDecoder/Decode/XDXFFmpegVideoDecoder.mm
 while (0 == avcodec_receive_frame(videoCodecContext, videoFrame))
 {
     CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)videoFrame->data[3];
     CMTime presentationTimeStamp = kCMTimeInvalid;
     int64_t originPTS = videoFrame->pts;
     int64_t newPTS    = originPTS - baseTime;
     presentationTimeStamp = CMTimeMakeWithSeconds(current_timestamp + newPTS * av_q2d(videoStream->time_base) , fps);
     CMSampleBufferRef sampleBufferRef = [self convertCVImageBufferRefToCMSampleBufferRef:(CVPixelBufferRef)pixelBuffer
                                                                withPresentationTimeStamp:presentationTimeStamp];
     
     if (sampleBufferRef) {
         if ([self.delegate respondsToSelector:@selector(getDecodeVideoDataByFFmpeg:)]) {
             [self.delegate getDecodeVideoDataByFFmpeg:sampleBufferRef];
         }
         
         CFRelease(sampleBufferRef);
     }
 }
 **/
//#pragma mark - Other
//+ (CMSampleBufferRef)convertCVImageBufferRefToCMSampleBufferRef:(CVImageBufferRef)pixelBuffer withPresentationTimeStamp:(CMTime)presentationTimeStamp{
//    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//    CMSampleBufferRef newSampleBuffer = NULL;
//    OSStatus res = 0;
//    CMSampleTimingInfo timingInfo;
//    timingInfo.duration              = kCMTimeInvalid;
//    timingInfo.decodeTimeStamp       = presentationTimeStamp;
//    timingInfo.presentationTimeStamp = presentationTimeStamp;
//    CMVideoFormatDescriptionRef videoInfo = NULL;
//    res = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
//    if (res != 0) {
//        //log4cplus_error(kModuleName, "%s: Create video format description failed!",__func__);
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//        return NULL;
//    }
//    res = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
//                                             pixelBuffer,
//                                             true,
//                                             NULL,
//                                             NULL,
//                                             videoInfo,
//                                             &timingInfo, &newSampleBuffer);
//    CFRelease(videoInfo);
//    if (res != 0) {
//      //  log4cplus_error(kModuleName, "%s: Create sample buffer failed!",__func__);
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//        return NULL;
//    }
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//    return newSampleBuffer;
//}

@end
