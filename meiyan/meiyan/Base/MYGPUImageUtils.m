//
//  MYGPUImageUtils.m
//  meiyan
//
//  Created by kzw on 2020/5/15.
//  Copyright © 2020 康子文. All rights reserved.
//

#import "MYGPUImageUtils.h"

@implementation MYGPUImageUtils
//gpimageView 应用
+(NSArray<UIImage *> *)sampleFilter{
    NSArray<UIImage *> *arr ;
    GPUImageFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
    UIImage *src = [UIImage imageNamed:@"test1"];
    UIImage *dst = [filter imageByFilteringImage:src];
    arr = @[src,dst];
    return arr;
}
@end
