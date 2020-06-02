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
//#import <GPUimag>
//#import <GPUImage/GPUImage.h>
static RGBBlock golbalRGBBlock = nil;
static VideoHandlerBlock globalvideoBlock = nil;
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
//接受rgb参数
+(void)dataRGB:(int)width height:(int)height r:(uint8_t *)r linsize:(int)linesize {
    NSLog(@"dataRGB...");
    CGSize size = CGSizeMake(width, height);
    if (golbalRGBBlock != nil) {
        golbalRGBBlock(r,size);
    }
}
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
//回调2 返回值用来标记是否停止解码 ，参数是进度百分比
static void videoData(void *data){
    struct VIDEOPARM *vs = (struct VIDEOPARM *)data;
    bool zd = [VideoUtils videData:vs->pro];
    vs->zhongduan = zd;
    NSLog(@"videoData : %f \n",vs->pro);
}
@end
