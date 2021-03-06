//
//  VideoUtils.h
//  ffmpegTest
//
//  Created by 康子文 on 2020/3/21.
//  Copyright © 2020 e-lead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN
//
//typedef  void (^RGBBlock)(GPUImageRawDataInput*);//(uint8_t *,CGSize);
typedef  void (^RGBBlock)(uint8_t *,CGSize);
typedef  void (^RGBABlock)(uint8_t *,CGSize);
typedef  void (^METALTextureBlock)( id<MTLTexture>, id<MTLTexture>);


typedef  bool (^VideoHandlerBlock)(float );

@interface VideoUtils : NSObject
+(NSString *)ffmpegConifg;
+(void)ffmpegGetPicture:(NSString *)src with:(NSString* )dst;
+(NSString *)ffmpegToMP4:(NSString *)src with:(NSString* )dst;
+(void) swsPicture:(NSString *)src block:(RGBBlock)rgbBlock;
// 视频解码
+(void)videoswsScaleplay:(NSString *)src block:(RGBBlock)rgbBlock handler:(VideoHandlerBlock)hBlock;
// 摄像头解码视频
+(void)creamswsScaleplay:(RGBBlock)rgbBlock handler:(VideoHandlerBlock)hBlock;
// 摄像头解码视频RGBA
+(void)creamswsRGBAScaleplay:(RGBABlock)rgbBlock handler:(VideoHandlerBlock)hBlock;
//硬件解码
+(void)videoswsHWRGBAScaleplay:(NSString *)src metal:(MTKView * )kView block:(METALTextureBlock)mBlock handler:(VideoHandlerBlock)hBlock ;
//avfilter 添加文字
+(void)ffmpegAddDrawText:(NSString *)src with:(NSString* )dst block:(RGBBlock)rgbBlock;
@end

NS_ASSUME_NONNULL_END
