//
//  MYCustomBitFilter.h
//  meiyan
//
//  Created by kzw on 2020/5/27.
//  Copyright © 2020 康子文. All rights reserved.
//

#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN
//二值图像
@interface MYCustomBitFilter : GPUImageFilter
@property(nonatomic,assign)CGFloat threshold; // 0.0 ~ 1.0

@end

NS_ASSUME_NONNULL_END
