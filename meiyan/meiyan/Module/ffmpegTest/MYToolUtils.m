//
//  MYToolUtils.m
//  meiyan
//
//  Created by kzw on 2020/5/22.
//  Copyright © 2020 康子文. All rights reserved.
//

#import "MYToolUtils.h"
#import <UIKit/UIKit.h>
//#import <GPUImage.h>
@implementation MYToolUtils
+(GPUImageRawDataInput*) imageToGLBytes:(UIImage *)image{
    //        UIImage *image = [UIImage imageNamed:@"img1.jpg"];
    CGImageRef newImageSource = [image CGImage];
    CFDataRef dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
    GLubyte* imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    GPUImageRawDataInput *onput = [[GPUImageRawDataInput alloc] initWithBytes:imageData size:image.size pixelFormat:GPUPixelFormatBGRA];
    return onput;
}
@end
